//
//  Exception.h
//  lara
//
//  Ported from darksword-kexploit-fun
//  Original by seo on 4/4/26.
//

#ifndef exc_h
#define exc_h

#import <mach/mach.h>
#import "RemoteCall.h"

// from pe_main.js
typedef struct {
    mach_msg_header_t       Head;
    uint64_t                NDR;
    uint32_t                exception;
    uint32_t                codeCnt;
    uint64_t                codeFirst;
    uint64_t                codeSecond;
    uint32_t                flavor;
    uint32_t                old_stateCnt;
    arm_thread_state64_internal    threadState;
    uint64_t                padding[2];
} excmsg;

typedef struct {
    mach_msg_header_t   Head;
    uint64_t            NDR;
    uint32_t            RetCode;
    uint32_t            flavor;
    uint32_t            new_stateCnt;
    arm_thread_state64_internal threadState;
} __attribute__((packed)) excreply;

mach_port_t createexcport(void);
bool waitexc(mach_port_t excport, excmsg *excbuf, int timeout, bool debug);
bool statereply(excmsg *exc, arm_thread_state64_internal *state);

#endif /* exc_h */
