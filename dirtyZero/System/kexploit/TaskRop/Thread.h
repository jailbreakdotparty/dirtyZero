//
//  thread.h
//  lara
//
//  Ported from darksword-kexploit-fun
//  Original by seo on 4/4/26.
//

#ifndef thread_h
#define thread_h

#import <stdbool.h>
#import <stdint.h>
#import <mach/mach.h>

#import "RemoteCall.h"

bool injectguardexc(uint64_t thread, uint64_t code);
void clearguardexc(uint64_t thread);
bool threadgetstate(mach_port_t machthread, arm_thread_state64_internal *outstate);
bool threadsetstate(mach_port_t machthread, uint64_t threadaddr, arm_thread_state64_internal *state);
bool threadresume(mach_port_t machthread);
void threadsetpac(uint64_t threadaddr, uint64_t keya, uint64_t keyb);

#endif /* thread_h */
