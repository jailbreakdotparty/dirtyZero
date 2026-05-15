//
//  findcachedataoff.m
//  lara
//
//  Rewritten by ruter on 14.05.26.
//

@import Foundation;
@import Darwin;
@import MachO;

long findcachedataoff(const char *mgkey) {
    const struct mach_header_64 *header = NULL;
    const char *mgname = "/usr/lib/libMobileGestalt.dylib";

    dlopen(mgname, RTLD_GLOBAL);

    for (int i = 0; i < _dyld_image_count(); i++) {
        if (!strncmp(mgname, _dyld_get_image_name(i), strlen(mgname))) {
            header = (const struct mach_header_64 *)_dyld_get_image_header(i);
            break;
        }
    }

    assert(header);

    size_t textcssize;
    const char *textcssizesect = (const char *)getsectiondata(header, "__TEXT", "__cstring", &textcssize);

    for (size_t size = 0; size < textcssize; size += strlen(textcssizesect + size) + 1) {
        if (!strncmp(mgkey, textcssizesect + size, strlen(mgkey))) {
            textcssizesect += size;
            break;
        }
    }

    size_t constsize;

    const uintptr_t *constsect = (const uintptr_t *)getsectiondata(header, "__AUTH_CONST", "__const", &constsize);

    if (!constsect) {
        constsect = (const uintptr_t *)getsectiondata(header, "__DATA_CONST", "__const", &constsize);
    }

    for (int i = 0; i < constsize / 8; i++) {
        if (constsect[i] == (uintptr_t)textcssizesect) {
            constsect += i;
            break;
        }
    }

    return (long)(((uint16_t *)constsect)[0x9a / 2] << 3);
}
