//
//  Exception.m
//  lara
//
//  Original by seo on 4/4/26.
//

#import "exc.h"
#import "RemoteCall.h"
#import "pac.h"
#import "offsets.h"
#import <Foundation/Foundation.h>
#import <mach/mach.h>

// xnu-10002.81.5/osfmk/mach/port.h
#define MPO_PROVISIONAL_ID_PROT_OPTOUT     0x8000
#define _EXC_FLAGS_NO_PTRAUTH        0x1
#define _EXC_FLAGS_IB_SIGNED_LR      0x2
#define _EXC_FLAGS_KERNEL_SIGNED_PC   0x4
#define _EXC_FLAGS_KERNEL_SIGNED_LR   0x8

#define EXCEPTION_MSG_SIZE              0x160
#define EXCEPTION_REPLY_SIZE            0x13c

mach_port_t createexcport(void) {
    mach_port_options_t options = {
        .flags = MPO_INSERT_SEND_RIGHT | MPO_PROVISIONAL_ID_PROT_OPTOUT,
        .mpl   = { .mpl_qlimit = 0 }
    };

    mach_port_t excport = MACH_PORT_NULL;

    kern_return_t kr = mach_port_construct(mach_task_self_, &options, 0, &excport);
    if (kr != KERN_SUCCESS) {
        printf("(exc) failed to create exception port: %s (kr=%d)\n", mach_error_string(kr), kr);
        return MACH_PORT_NULL;
    }

    return excport;
}

bool waitexc(mach_port_t excport, excmsg *excbuf, int timeout, bool debug) {
    kern_return_t kr = mach_msg(&excbuf->Head, MACH_RCV_MSG | MACH_RCV_TIMEOUT, 0, EXCEPTION_MSG_SIZE, excport, timeout, MACH_PORT_NULL);
    if (kr != KERN_SUCCESS) return false;

    return true;
}

bool statereply(excmsg *exc, arm_thread_state64_internal *state) {
    uint8_t replybuf[EXCEPTION_REPLY_SIZE];
    memset(replybuf, 0, sizeof(replybuf));
    excreply *reply = (excreply *)replybuf;

    reply->Head.msgh_bits        = MACH_MSGH_BITS(MACH_MSG_TYPE_MOVE_SEND_ONCE, 0);
    reply->Head.msgh_size        = EXCEPTION_REPLY_SIZE;
    reply->Head.msgh_remote_port = exc->Head.msgh_remote_port;
    reply->Head.msgh_local_port  = MACH_PORT_NULL;
    reply->Head.msgh_id          = exc->Head.msgh_id + 100;
    reply->NDR                   = exc->NDR;
    reply->RetCode               = 0;
    reply->flavor                = ARM_THREAD_STATE64;
    reply->new_stateCnt          = ARM_THREAD_STATE64_COUNT;
    memcpy(&reply->threadState, state, sizeof(arm_thread_state64_t));

    kern_return_t kr = mach_msg((mach_msg_header_t *)replybuf,
                                MACH_SEND_MSG,
                                EXCEPTION_REPLY_SIZE, 0,
                                MACH_PORT_NULL,
                                MACH_MSG_TIMEOUT_NONE,
                                MACH_PORT_NULL);
    if (kr != KERN_SUCCESS) {
        printf("(exc) statereply failed: %s\n", mach_error_string(kr));
        return false;
    }
    return true;
}
