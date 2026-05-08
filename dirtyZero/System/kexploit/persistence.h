//
//  persistence.h
//  darksword-kexploit-fun
//
//  Created by Duy Tran on 11/4/26.
//

#import "darksword.h"
@import Darwin;

extern kern_return_t bootstrap_register(mach_port_t bp, const char *service_name, mach_port_t sp);
extern kern_return_t bootstrap_look_up(mach_port_t bp, const char *service_name, mach_port_t *sp);
extern kern_return_t bootstrap_unregister(mach_port_t bp, const char *service_name);

int64_t sandbox_extension_consume(const char *extension_token);
char *sandbox_extension_issue_mach(const char *extension_class, const char *name, uint32_t flags);

#define CONTROL_PORT_NAME "krw.darksword.control_port"
#define RW_PORT_NAME "krw.darksword.rw_port"
#define APP_MACH_LOOKUP "com.apple.security.exception.mach-lookup.global-name"
#define APP_MACH_REGISTER "com.apple.security.exception.mach-register.global-name"

bool transfer_krw_to_launchd(void);
bool recover_krw_primitives(void);
