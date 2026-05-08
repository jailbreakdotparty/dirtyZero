//
//  vfs.h
//  lara
//
//  Created by ruter on 28.03.26.
//

#ifndef vfs_h
#define vfs_h

#include <stdint.h>
#include <stddef.h>
#include <stdbool.h>
#include <sys/types.h>

typedef void (*vfs_logcallback)(const char *message);
void vfs_setlogcallback(vfs_logcallback cb);
typedef void (*vfs_progress_callback_t)(double progress);
void vfs_setprogresscallback(vfs_progress_callback_t cb);

typedef struct {
    char name[256];
    uint8_t d_type;
} vfs_entry_t;

int  vfs_init(void);
bool vfs_isready(void);

int  vfs_listdir(const char *path, vfs_entry_t **out, int *count);
void vfs_freelisting(vfs_entry_t *entries);

int64_t vfs_read(const char *path, void *buf, size_t size, off_t offset);
int64_t vfs_write(const char *path, const void *buf, size_t size, off_t offset);

int64_t vfs_filesize(const char *path);

int vfs_overwritefile(const char *to, const char *from);
int vfs_overwritebytes(const char *path, off_t offset, const void *data, size_t len);
int vfs_zerofile(const char *path);
int vfs_zeropage(const char *path, off_t offset);

#endif /* vfs_h */
