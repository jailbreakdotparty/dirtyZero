//
//  dirtyZeroApp.swift
//  dirtyZero
//
//  Created by Skadz on 5/8/25.
//

import SwiftUI
import PartyUI
import DeviceKit

var weOnADebugBuild: Bool = false
var pipe = Pipe()
var sema = DispatchSemaphore(value: 0)

@main
struct dirtyZeroApp: App {
    @StateObject private var mgr = dirtyZeroManager.shared
    @AppStorage("enableDebugSettings") var enableDebugSettings: Bool = false
    @AppStorage("storedChosenExploit") var storedChosenExploit: ExploitOptions = defaultExploit()
    
    let device = Device.current
    
    init() {
        // Setup log stuff (redirect stdout)
        setvbuf(stdout, nil, _IONBF, 0)
        dup2(pipe.fileHandleForWriting.fileDescriptor, STDOUT_FILENO)
        
        // Give us a debug build bool
        #if DEBUG
        weOnADebugBuild = true
        enableDebugSettings = true
        #else
        weOnADebugBuild = false
        #endif
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(mgr)
                .overlay {
                    if mgr.showRespringView {
                        RespringView()
                            .brightness(-1.0)
                            .ignoresSafeArea()
                    }
                }
                .onAppear {
                    if mgr.isDirtyZeroSupported {
                        mgr.hasOffsets = checkForOffsets()
                        mgr.chosenExploit = storedChosenExploit
                        
                        if mgr.chosenExploit == .DarkSword && mgr.hasOffsets {
                            init_offsets()
                            offsets_init()
                        } else if mgr.chosenExploit == .l0ckwire {
                            mgr.isDirtyZeroReady = true
                        }
                        print("[*] Welcome to dirtyZero! Running on \(device.systemName ?? "nil") \(device.systemVersion ?? "0.0"), \(device.description).")
                        print("[*] All tweaks are done in memory, so if something goes wrong, simply reboot your device.")
                    } else {
                        Alertinator.shared.alert(title: "This device combination is not supported.", body: "This device combination is not supported and never will be. dirtyZero only supports iOS 16.0 - iOS 18.7.1, and iOS 26.0 - iOS 26.0.1.", showCancel: false, action: { exitinator() })
                    }
                }
                .onChange(of: mgr.chosenExploit) { exploit in
                    if exploit == .DarkSword && mgr.hasOffsets {
                        init_offsets()
                        offsets_init()
                        
                        if !mgr.dsready || !mgr.vfsready {
                            mgr.isDirtyZeroReady = false
                            mgr.applyShortStatus = "Waiting for DarkSword..."
                            mgr.applyIcon = "xmark.circle.fill"
                            mgr.applyColor = .secondary
                        }
                    } else if exploit == .l0ckwire {
                        mgr.applyShortStatus = "Ready to Apply!"
                        mgr.applyIcon = "checkmark.circle.fill"
                        mgr.applyColor = Color(.label)
                    }
                }
                .onChange(of: mgr.chosenExploit) { newValue in
                    storedChosenExploit = newValue
                }
        }
    }
}

@MainActor func isdirtyZeroSupported() -> Bool {
    return doubleSystemVersion() <= 26.0
}

extension String: @retroactive Error {}

// allows us to put arrays into AppStorage
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
