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
    @StateObject private var mgr = dirtyZeroManager.shared
    
    @AppStorage("enableDebugSettings") var enableDebugSettings: Bool = false
    
    let device = UIDevice.current
    
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
                    if isSupported() {
                        print("\n[*] Welcome to dirtyZero! Running on \(device.systemName) \(device.systemVersion), \(device.model).")
                        print("[*] All tweaks are done in memory, so if something goes wrong, simply reboot your device.")
                    } else {
                        Alertinator.shared.alert(title: "This app is not supported!", body: "Your device configuration does not support dirtyZero. This tool only supports devices running iOS 16.0 - iOS 18.3, and will never support anything else.", actionLabel: "Exit", action: {
                            exitinator()
                        })
                    }
                }
        }
    }
}

@MainActor func isSupported() -> Bool {
    return doubleSystemVersion() <= 18.3
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

// hex -> color
extension Color {
    init(hex: String) {
        let v = Int("000000" + hex, radix: 16) ?? 0
        let r = CGFloat(v / Int(powf(256, 2)) % 256) / 255
        let g = CGFloat(v / Int(powf(256, 1)) % 256) / 255
        let b = CGFloat(v / Int(powf(256, 0)) % 256) / 255
        self.init(red: r, green: g, blue: b)
    }
}

// color -> hex
func hexCode(color: Color) -> String {
    let ui = UIColor(color)
    var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0
    guard ui.getRed(&r, green: &g, blue: &b, alpha: nil) else { return "" }
    return [r, g, b].reduce("") { res, v in
        res + String(format: "%02X", Int(round(v * 255)))
    }
}
