//
//  dirtyZeroApp.swift
//  dirtyZero
//
//  Created by Skadz on 5/8/25.
//

import SwiftUI
import PartyUI

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
            MainView()
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

@MainActor func isdirtyZeroSupported() -> Bool {
    return doubleSystemVersion() <= 18.3
}

extension Array: @retroactive RawRepresentable where Element: Codable {
    public init?(rawValue: String) {
        guard let data = rawValue.data(using: .utf8),
              let result = try? JSONDecoder().decode([Element].self, from: data)
        else {
            return nil
        }
        self = result
    }
    
    public var rawValue: String {
        guard let data = try? JSONEncoder().encode(self),
              let result = String(data: data, encoding: .utf8)
        else {
            return "[]"
        }
        return result
    }
}
