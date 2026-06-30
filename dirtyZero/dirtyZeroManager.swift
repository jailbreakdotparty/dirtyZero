//
//  dirtyZeroManager.swift
//  dirtyZero
//
//  Created by lunginspector on 4/14/26.
//

import SwiftUI
import PartyUI

@MainActor
final class dirtyZeroManager: ObservableObject {
    static let shared = dirtyZeroManager()
    
    // tweak counts
    @Published var enabledTweaks: Int = 0
    
    // status information
    @Published var applyStatus: String = ""
    @Published var applyShortStatus: String = "Ready to Apply!"
    @Published var applyIcon: String = "checkmark.circle.fill"
    @Published var applyColor: Color = Color(.label).opacity(0.8)
    
    @Published var applyCurrentTweak: Int = 0
    @Published var applyCurrentTweakName: String = ""
    
    // tell app to do stuff
    @Published var showRespringView: Bool = false
    
    // imported AppStorage properties, only requried for reading.
    @AppStorage("useRespringApp") var useRespringApp: Bool = false
    @AppStorage("respringAppBID") var respringAppBID: String = "com.jbdotparty.respringr"
    
    init() {}
    
    @MainActor func applyTweaks(tweakData: [ZeroSection]) {
        applyCurrentTweak = 0
        var failedTweaks = 0
        var failedTweaksArray: [ZeroTweak] = []
        let tweaks = tweakData.flatMap { $0.tweaks }.filter { $0.isOn }
        
        for tweak in tweaks {
            applyCurrentTweak += 1
            applyCurrentTweakName = tweak.name
            
            print("[*] (\(applyCurrentTweak)/\(enabledTweaks)) zeroing paths for the tweak \(tweak.name): \(tweak.paths)")
            
            for path in tweak.paths {
                do {
                    try zeroAtPath(path: path)
                } catch {
                    failedTweaks += 1
                    failedTweaksArray.append(tweak)
                    print("[!] (\(applyCurrentTweak)/\(enabledTweaks)) failed to apply the tweak \(tweak.name) at path \(path): \(error)")
                }
            }
        }
        
        if failedTweaksArray.isEmpty {
            applyStatus = "Respring your device for changes to take effect."
            applyShortStatus = "Successfully Applied!"
            applyIcon = "checkmark.circle.fill"
            applyColor = .green
            
            print("[*] all tweaks applied successfully!")
            Alertinator.shared.alert(title: "All tweaks applied successfully!", body: "Respring your device for changes take effect.", actionLabel: "Respring", action: {
                self.respringDevice()
            })
        } else {
            applyStatus = "\(failedTweaks)/\(enabledTweaks) tweaks failed to apply. You can still respring to apply the tweaks that did succeed."
            applyShortStatus = "Failed to Apply!"
            applyIcon = "xmark.circle.fill"
            applyColor = .red
            
            let names = failedTweaksArray.compactMap { $0.name }.joined(separator: ", ")
            print("[!] \(failedTweaks)/\(enabledTweaks) tweaks failed to apply: \(names)")
            Alertinator.shared.alert(title: "\(failedTweaks)/\(enabledTweaks) tweaks failed to apply!", body: "The following tweaks failed to apply: \(names). Some tweaks did still apply though, so you can respring if you're ok with not having the mentioned tweaks. Check error logs for more detailed information.", actionLabel: "Respring", action: {
                self.respringDevice()
            })
        }
    }
    
    @MainActor func revertTweaks() {
        Alertinator.shared.alert(title: "Device Will Reboot", body: "To revert all of your tweaks, your device must reboot. Would you like to do this now?", actionLabel: "Reboot", action: {
            do {
                try zeroAtPath(path: "/usr/lib/dyld")
            } catch {
                print("[!] failed to reboot device: \(error)")
                Alertinator.shared.alert(title: "Failed to reboot device!", body: "\(error)")
            }
        })
    }
    
    func respringDevice() {
        if !useRespringApp {
            print("[*] attempting to respring device...")
            showRespringView = true
        } else {
            if isAppInstalled(respringAppBID) {
                LSApplicationWorkspace.default().openApplication(withBundleID: respringAppBID)
            } else if isAppInstalled("com.respring.app") { // check if old respringapp is installed
                LSApplicationWorkspace.default().openApplication(withBundleID: "com.respring.app")
            } else {
                print("[!] failed to find respringapp, aborting...")
                Alertinator.shared.alert(title: "RespringApp Not Detected", body: "Make sure you have RespringApp installed, then try again.", actionLabel: "Respring Without RespringApp", action: {
                    print("[*] attempting to respring device...")
                    self.showRespringView = true
                })
            }
        }
    }
    
    // funny "sandbox escape" that was also patched in 18.4
    func isAppInstalled(_ bundleID: String) -> Bool {
        typealias SBSLaunchFunction = @convention(c) (
            String,
            URL?,
            [String: Any]?,
            [String: Any]?,
            Bool
        ) -> Int32
        
        guard let sbsLib = dlopen("/System/Library/PrivateFrameworks/SpringBoardServices.framework/SpringBoardServices", RTLD_NOW) else {
            print("[!] dlopen fail !!")
            return false
        }
        
        defer {
            dlclose(sbsLib)
        }
        
        guard let sbsAddr = dlsym(sbsLib, "SBSLaunchApplicationWithIdentifierAndURLAndLaunchOptions") else {
            print("[!] dlsym fail !!")
            return false
        }
        
        let sbsFunction = unsafeBitCast(sbsAddr, to: SBSLaunchFunction.self)
        
        let result = sbsFunction(bundleID, nil, nil, nil, true)
        
        return result == 9
    }
}
