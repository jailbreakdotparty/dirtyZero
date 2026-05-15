//
//  vnode.m
//  lara
//
//  Created by ruter on 13.04.26.
//

#import "vnode.h"
#import "darksword.h"
#import "utils.h"
#import "offsets.h"
#import "xpaci.h"

#import <stdlib.h>
#import <unistd.h>
#import <fcntl.h>
#import <stdbool.h>
#import <string.h>
#import <Foundation/Foundation.h>
#import <sys/stat.h>

uint64_t vnodebychdir(const char *path) {
    if (access(path, F_OK) == -1) {
        return -1;
    }
    if (chdir(path) == -1) { return -1; }
    
    uint64_t fd_cdir_vp = ds_kread64(ds_get_our_proc() + off_proc_p_fd + off_filedesc_fd_cdir);
    chdir("/");
    return fd_cdir_vp;
}

uint64_t vnodebyfd(int fd) {
    uint64_t fileprocptrarray = ds_kread64(ds_get_our_proc() + off_proc_p_fd + off_filedesc_fd_ofiles);
    fileprocptrarray = xpaci(fileprocptrarray);
    uint64_t fileproc = ds_kread64(fileprocptrarray + (8 * fd));
    uint64_t fpglob = ds_kread64(fileproc + off_fileproc_fp_glob);
    fpglob = xpaci(fpglob);
    uint64_t vnode = ds_kread64(fpglob + off_fileglob_fg_data);
    vnode = xpaci(vnode);
    
    return vnode;
}

uint64_t vnodebyopen(const char *path) {
    int fd = open(path, O_RDONLY);
    if (fd == -1) return -1;
    
    uint64_t vnode = vnodebyfd(fd);
    vnode = xpaci(vnode);
    
    close(fd);
    return vnode;
}

uint64_t vn_folderredirect(const char *to, const char *from) {
    uint64_t to_vnode = vnodebychdir(to);
    uint64_t orig_to_v_data = ds_kread64(to_vnode + off_vnode_v_data);
    uint64_t from_vnode = vnodebychdir(from);
    uint64_t from_v_data = ds_kread64(from_vnode + off_vnode_v_data);
    
    ds_kwrite64(to_vnode + off_vnode_v_data, from_v_data);
    
    return orig_to_v_data;
}

bool vn_folderunredirect(const char *folder, uint64_t orig_to_v_data) {
    uint64_t vnode = vnodebychdir(folder);
    if (vnode == -1) return false;
    
    ds_kwrite64(vnode + off_vnode_v_data, orig_to_v_data);
    
    return true;
}

char vp_name[256];
char* vn_vname(uint64_t vnode) {
    memset(vp_name, 0, 256);
    uint64_t vp_nameptr = ds_kread64(vnode + off_vnode_v_name);
    ds_kreadbuf(vp_nameptr, &vp_name, 256);
    return vp_name;
}

uint64_t vn_childvnode(uint64_t vnode, const char* child_filename, uint64_t blacklist_vdata) {
    uint64_t vp_namecache = ds_kread64(vnode + off_vnode_v_ncchildren_tqh_first);
    if(vp_namecache == 0)   return -1;
    
    while(1) {
        if(vp_namecache == 0)   break;
        vnode = ds_kread64(vp_namecache + off_namecache_nc_vp);
        
        if(vnode == 0)  break;
        char* vp_name = vn_vname(vnode);
        
        if(strcmp(vp_name, child_filename) == 0 && ds_kread64(vnode + off_vnode_v_data) != blacklist_vdata) {
            return vnode;
        }
        vp_namecache = ds_kread64(vp_namecache + off_namecache_nc_child_tqe_next);
    }
    
    return -1;
}

bool vn_fileredirect(const char *to, const char *from, uint64_t* orig_to_vnode, uint64_t* orig_to_v_data) {
    uint64_t to_vnode = vnodebyopen(to);
    if(to_vnode == -1) {
        NSString *to_dir = [[NSString stringWithUTF8String:to] stringByDeletingLastPathComponent];
        NSString *to_file = [[NSString stringWithUTF8String:to] lastPathComponent];
        uint64_t to_dir_vnode = vnodebychdir(to_dir.UTF8String);
        to_vnode = vn_childvnode(to_dir_vnode, to_file.UTF8String, 0);
        if(to_vnode == -1) {
            printf("couldn't find file (to): %s", to);
            return false;
        }
    }
    
    uint64_t from_vnode = vnodebyopen(from);
    if(from_vnode == -1) {
        NSString *from_dir = [[NSString stringWithUTF8String:from] stringByDeletingLastPathComponent];
        NSString *from_file = [[NSString stringWithUTF8String:from] lastPathComponent];
        uint64_t from_dir_vnode = vnodebychdir(from_dir.UTF8String);
        from_vnode = vn_childvnode(from_dir_vnode, from_file.UTF8String, 0);
        if(from_vnode == 0) {
            printf("couldn't find file (from): %s", from);
            return false;
        }
    }
    
    *orig_to_vnode = to_vnode;
    *orig_to_v_data = ds_kread64(to_vnode + off_vnode_v_data);
    uint64_t from_v_data = ds_kread64(from_vnode + off_vnode_v_data);
    ds_kwrite64(to_vnode + off_vnode_v_data, from_v_data);
    
    return true;
}

bool vn_fileunredirect(uint64_t orig_to_vnode, uint64_t orig_to_v_data) {
    ds_kwrite64(orig_to_vnode + off_vnode_v_data, orig_to_v_data);
    
    return true;
}

uint64_t vn_fsnode(uint64_t vp) {
    return ds_kread64(vp + off_vnode_v_data);
}
