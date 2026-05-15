//
//  pac.h
//  lara
//
//  Ported from darksword-kexploit-fun
//  Original by seo on 4/4/26.
//

#ifndef pac_h
#define pac_h

#import <stdint.h>
#import <stdbool.h>
#import <mach/mach.h>

uint64_t nativestrip(uint64_t address);
uint64_t pacia(uint64_t ptr, uint64_t modifier);
uint64_t ptrauthblend(uint64_t diver, uint64_t discriminator);
uint64_t ptrauthstrdisc(const char *name);
bool pacsignworks(void);
uint64_t findpacia(void);
void paccleanup(mach_port_t pacthread, mach_port_t excport, void *stack);
uint64_t remotepac(uint64_t remotethreadaddr, uint64_t address, uint64_t modifier);

#endif /* pac_h */
