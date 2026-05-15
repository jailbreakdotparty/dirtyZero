//
//  getbmhash.swift
//  lara
//
//  Created by ruter on 12.05.26.
//

import Foundation

func getbmhash() -> String? {
    let path = "/private/preboot"
    let fm = FileManager.default
    let regex = try! NSRegularExpression(pattern: "^[A-Fa-f0-9]{64,128}$")

    guard let enumerator = fm.enumerator(atPath: path) else {
        print("(getbmhash) failed to enumerate path: \(path)")
        return nil
    }

    for case let file as String in enumerator {
        let name = (file as NSString).lastPathComponent
        let range = NSRange(name.startIndex..<name.endIndex, in: name)

        if regex.firstMatch(in: name, range: range) != nil {
            print("(getbmhash) matching hash found: \(name)")
            return name
        }
    }

    print("(getbmhash) no matching hash found")
    return nil
}
