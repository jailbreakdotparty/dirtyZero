//
//  dirtyZeroApp.swift
//  dirtyZero
//
//  Created by Skadz on 5/8/25.
//

import SwiftUI
import PartyUI
import DeviceKit
import UniformTypeIdentifiers

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
        // file picker fix
        let fixMethod = class_getInstanceMethod(UIDocumentPickerViewController.self, #selector(UIDocumentPickerViewController.fix_init(forOpeningContentTypes:asCopy:)))!
        let origMethod = class_getInstanceMethod(UIDocumentPickerViewController.self, #selector(UIDocumentPickerViewController.init(forOpeningContentTypes:asCopy:)))!
        method_exchangeImplementations(origMethod, fixMethod)
        
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
                    mgr.setAppCapabilities()
                    
                    if mgr.isSupported {
                        if mgr.chosenExploit == .l0ckwire {
                            mgr.isReady = true
                            mgr.applyShortStatus = "Ready to Apply!"
                            mgr.applyIcon = "checkmark.circle.fill"
                            mgr.applyColor = Color(.label)
                        } else {
                            mgr.hasOffsets = emergencyfixfunctiontobereplacedlateronquestionmark()
    
                            init_offsets()
                            offsets_init()
                            
                            if mgr.hasOffsets {
                                mgr.applyShortStatus = "Waiting for DarkSword..."
                                mgr.applyIcon = "xmark.circle.fill"
                                mgr.applyColor = .secondary
                            } else {
                                mgr.applyShortStatus = "No kernelcache found!"
                                mgr.applyIcon = "exclamationmark.triangle.fill"
                                mgr.applyColor = Color.yellow
                            }
                        }
                        print("[*] Welcome to dirtyZero! Running on \(device.systemName ?? "nil") \(device.systemVersion ?? "0.0"), \(device.description).")
                        print("[*] All tweaks are done in memory, so if something goes wrong, simply reboot your device.")
                    } else {
                        mgr.applyShortStatus = "Unsupported device!"
                        mgr.applyIcon = "xmark.circle.filll"
                        mgr.applyColor = .red
                        
                        Alertinator.shared.alert(title: "This device combination is not supported.", body: "This device combination is not supported and never will be. dirtyZero only supports iOS 16.0 - iOS 18.7.1, and iOS 26.0 - iOS 26.0.1.", action: { exitinator() })
                    }
                }
                .onChange(of: mgr.chosenExploit) { exploit in
                    storedChosenExploit = exploit
                    
                    if exploit == .l0ckwire {
                        mgr.applyShortStatus = "Ready to Apply!"
                        mgr.applyIcon = "checkmark.circle.fill"
                        mgr.applyColor = Color(.label)
                    } else {
                        mgr.hasOffsets = emergencyfixfunctiontobereplacedlateronquestionmark()
                        
                        if mgr.hasOffsets {
                            init_offsets()
                            offsets_init()
                            
                            if !mgr.dsready || !mgr.vfsready {
                                mgr.isReady = false
                                mgr.applyShortStatus = "Waiting for DarkSword..."
                                mgr.applyIcon = "xmark.circle.fill"
                                mgr.applyColor = .secondary
                            } else if mgr.dsready && mgr.vfsready {
                                mgr.applyShortStatus = "Ready to Apply!"
                                mgr.applyIcon = "checkmark.circle.fill"
                                mgr.applyColor = Color(.label)
                            }
                        } else if !mgr.hasOffsets {
                            mgr.isReady = false
                            mgr.applyShortStatus = "No kernelcache found!"
                            mgr.applyIcon = "exclamationmark.triangle.fill"
                            mgr.applyColor = Color.yellow
                        }
                    }
                }
        }
    }
}

// file picker fixes
extension UIDocumentPickerViewController {
    @objc func fix_init(forOpeningContentTypes contentTypes: [UTType], asCopy: Bool) -> UIDocumentPickerViewController {
        return fix_init(forOpeningContentTypes: contentTypes, asCopy: true)
    }
}

// allows us to throw strings as errors
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
