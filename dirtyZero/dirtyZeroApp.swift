//
//  dirtyZeroApp.swift
//  dirtyZero
//
//  Created by Skadz on 5/8/25.
//

import SwiftUI

var weOnADebugBuild: Bool = false
var pipe = Pipe()
var sema = DispatchSemaphore(value: 0)

@main
struct dirtyZeroApp: App {
    init() {
        // Setup log stuff (redirect stdout)
        setvbuf(stdout, nil, _IONBF, 0)
        dup2(pipe.fileHandleForWriting.fileDescriptor, STDOUT_FILENO)
        
        // Give us a debug build bool
        #if DEBUG
        weOnADebugBuild = true
        #else
        weOnADebugBuild = false
        #endif
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear(perform: {
                    if weOnADebugBuild { print("We're on a Debug build!") }
                })
        }
    }
}

extension String: @retroactive Error {}

extension UIApplication {
    static var appVersion: String? {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    }
}

func doubleSystemVersion() -> Double {
    let rawSystemVersion = UIDevice.current.systemVersion
    let parsedSystemVersion = rawSystemVersion.split(separator: ".").prefix(2).joined(separator: ".")
    return Double(parsedSystemVersion) ?? 0.0
}

func isdirtyZeroSupported() -> Bool {
    return doubleSystemVersion() <= 18.3
}
