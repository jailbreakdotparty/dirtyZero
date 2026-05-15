//
//  xpaci.m
//  lara
//
//  Created by ruter on 13.04.26.
//

#include <stdbool.h>
#include <sys/sysctl.h>
#include <mach/machine.h>
#import "darksword.h"

static bool ispac(void) {
    cpu_subtype_t cpusubtype = 0;
    size_t sz = sizeof(cpusubtype);

    if (sysctlbyname("hw.cpusubtype", &cpusubtype, &sz, NULL, 0) != 0) {
        return false;
    }

    return (cpusubtype == CPU_SUBTYPE_ARM64E);
}

static bool gispac(void) {
    static bool checked = false;
    static bool result = false;
    
    if (!checked) {
        result = ispac();
        checked = true;
    }
    return result;
}

static uint64_t __attribute((naked)) __xpaci(uint64_t a) {
    asm(".long        0xDAC143E0"); // XPACI X0
    asm("ret");
}

static uint64_t xpaci(uint64_t a) {
    if(!gispac()) return a;
    
    if ((a & 0xFFFFFF0000000000) == 0xFFFFFF0000000000) {
        return a;
    }
    
    return __xpaci(a);
}
