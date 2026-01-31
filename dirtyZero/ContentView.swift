//
//  ContentView.swift
//  dirtyZero
//
//  Created by Skadz on 5/8/25.
//

import SwiftUI
import PartyUI
import DeviceKit
import UIKit

struct ZeroTweak: Identifiable, Codable, Equatable {
    var id: String { name }
    var icon: String
    var name: String
    var minSupportedVersion: Double
    var maxSupportedVersion: Double
    var paths: [String]
    
    enum CodingKeys: String, CodingKey {
        case icon, name, minSupportedVersion, maxSupportedVersion, paths
    }
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

// i really really hate this
// however i'm tired and i just want it to work
// lung you're never touching this app again (joke)
// here lies the few remaining fucks i had to give
// - Skadz, 10/10/25 9:27 PM
var applyingString: String = "idk boss"
var appliedString: String = "idk either boss"
var failedString: String = "shit me i did a fuck"

enum TweakApplyingStatuses: String, CaseIterable {
    case ready = "Ready to Apply"
    case applying = "Applying Tweaks..."
    case applied = "Applied Tweaks"
    case failed = "Failed to Apply"
    
    var description: String {
        switch self {
        case .ready: return "All tweaks are done in memory, so if something goes wrong, you can force reboot to revert changes."
        case .applying: return applyingString
        case .applied: return appliedString
        case .failed: return failedString
        }
    }
}

struct ContentView: View {
    let device = Device.current
    @AppStorage("enabledTweaks") private var enabledTweakIds: [String] = []
    
    @State private var hasShownWelcome = false
    @State private var customZeroPath: String = ""
    @State private var addedCustomPaths: [String] = []
    @State private var isSupported: Bool = true
    @State private var showSettingsPopover: Bool = false
    @State private var showCustomTweaksPopover: Bool = false
    @State private var tweakApplicationStatus: TweakApplyingStatuses = TweakApplyingStatuses.ready
    @State private var tweakApplicationMessage: String = TweakApplyingStatuses.ready.rawValue
    @State private var debugSettingsExpanded: Bool = false
    
    @FocusState private var isCustomPathFieldFocused: Bool
    
    @AppStorage("showLogs") private var showLogs: Bool = true
    @AppStorage("showDebugSettings") private var showDebugSettings: Bool = false
    @AppStorage("showRiskyTweaks") private var showRiskyTweaks: Bool = false
    @AppStorage("respringAppBID") private var respringAppBID: String = "com.respring.app"
    @AppStorage("customTweaks") private var customTweaks: [ZeroTweak] = []
    
    private var tweaks: [ZeroTweak] {
        homeScreen + lockScreen + alertsOverlays + fontsIcons + controlCenter + soundEffects + riskyTweaks + customTweaks
    }
    
    private var enabledTweaks: [ZeroTweak] {
        tweaks.filter { tweak in enabledTweakIds.contains(tweak.id) }
    }
    
    private func isTweakEnabled(_ tweak: ZeroTweak) -> Bool {
        enabledTweakIds.contains(tweak.id)
    }
    
    private func toggleTweak(_ tweak: ZeroTweak) {
        if isTweakEnabled(tweak) {
            enabledTweakIds.removeAll { $0 == tweak.id }
        } else {
            enabledTweakIds.append(tweak.id)
        }
    }
    
    var body: some View {
        NavigationStack {
            List {
                Section(header: HeaderLabel(text: "Version \(UIApplication.appVersion!) (\(weOnADebugBuild ? "Debug" : "Release"))", icon: "info.circle"), footer: Text("Made with love by the [jailbreak.party](https://jailbreak.party/) team.\n[Join the jailbreak.party Discord!](https://jailbreak.party/discord)").font(.footnote)) {
                    VStack {
                        VStack(alignment: .leading) {
                            HStack {
                                if tweakApplicationStatus == .applying {
                                    ProgressView()
                                } else if tweakApplicationStatus == .failed {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundStyle(.red)
                                } else if tweakApplicationStatus == .ready {
                                    Image(systemName: "checkmark.circle.fill")
                                        .opacity(0.6)
                                } else {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(.green)
                                }
                                Text(tweakApplicationStatus.rawValue)
                            }
                            if showLogs {
                                TerminalContainer(content: VStack { LogView() })
                            } else {
                                Text(tweakApplicationStatus.description)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .font(.body)
                                    .multilineTextAlignment(.leading)
                                    .opacity(0.8)
                            }
                        }
                        .padding()
                        .modifier(DynamicGlassEffect())
                        .frame(maxWidth: .infinity, alignment: .leading)
                        HStack {
                            HStack {
                                Image(systemName: device.isPad ? "ipad" : "iphone.gen2")
                                    .frame(width: 20, height: 20)
                                Text("\(device.systemName!) \(device.systemVersion!)")
                            }
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(10)
                            .background(Color(.quaternarySystemFill))
                            .cornerRadius(conditionalCornerRadius())
                            
                            HStack {
                                Image(systemName: "wrench.and.screwdriver")
                                    .frame(width: 20, height: 20)
                                if enabledTweaks.count == 1 {
                                    Text("\(enabledTweaks.count) tweak")
                                } else {
                                    Text("\(enabledTweaks.count) tweaks")
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(10)
                            .background(Color(.quaternarySystemFill))
                            .cornerRadius(conditionalCornerRadius())
                        }
                    }
                }
                .listRowSeparator(.hidden)
                
                if weOnADebugBuild || showDebugSettings {
                    Section(header: HeaderDropdown(text: "Debugging", icon: "ant", isExpanded: $debugSettingsExpanded)) {
                        if debugSettingsExpanded {
                            VStack {
                                HStack {
                                    TextField("/path/to/zero", text: $customZeroPath)
                                        .textFieldStyle(GlassyTextFieldStyle( ))
                                    Button(action: {
                                        Haptic.shared.play(.soft)
                                        customZeroPath = UIPasteboard.general.string ?? ""
                                    }) {
                                        Image(systemName: "doc.on.doc")
                                            .frame(width: 18, height: 24)
                                    }
                                    .buttonStyle(GlassyButtonStyle(useFullWidth: false))
                                    Button(action: {
                                        Haptic.shared.play(.heavy)
                                        if customZeroPath.isEmpty {
                                            Alertinator.shared.alert(title: "Invaild Path", body: "Please enter a vaild path.")
                                        } else {
                                            try? zeroPoC(path: customZeroPath)
                                            Alertinator.shared.alert(title: "Attempted to Zero", body: "Attempted to zero out \(customZeroPath).", actionLabel: "Respring", action: {
                                                if isDatAppInstalled(respringAppBID) {
                                                    LSApplicationWorkspace.default().openApplication(withBundleID: respringAppBID)
                                                } else {
                                                    Alertinator.shared.alert(title: "RespringApp Not Detected", body: "Make sure you have RespringApp installed, then try again.")
                                                }
                                            })
                                        }
                                    }) {
                                        Image(systemName: "checkmark")
                                            .frame(width: 18, height: 24)
                                    }
                                    .buttonStyle(GlassyButtonStyle(useFullWidth: false))
                                }
                                Button(action: {
                                    Haptic.shared.play(.soft)
                                    print("===== dirtyZero Debug =====\n[*] isSupported: \(isSupported)\n[*] weOnADebugBuild: \(weOnADebugBuild)\n[*] enabledTweakIds: \(enabledTweakIds)\n[*] customTweaks: \(customTweaks)")
                                }) {
                                    ButtonLabel(text: "Print Debug Info", icon: "ant")
                                }
                                .buttonStyle(GlassyButtonStyle())
                            }
                        }
                    }
                    .listRowSeparator(.hidden)
                    .animation(.default, value: debugSettingsExpanded)
                }
                TweakSectionList(sectionLabel: "Custom Tweaks", sectionIcon: "wrench.and.screwdriver", tweaks: customTweaks, isCustomTweak: true, enabledTweakIds: $enabledTweakIds)
                TweakSectionList(sectionLabel: "Home Screen", sectionIcon: "house", tweaks: homeScreen, enabledTweakIds: $enabledTweakIds)
                TweakSectionList(sectionLabel: "Lock Screen", sectionIcon: "lock", tweaks: lockScreen, enabledTweakIds: $enabledTweakIds)
                TweakSectionList(sectionLabel: "Alerts & Overlays", sectionIcon: "exclamationmark.triangle", tweaks: alertsOverlays, enabledTweakIds: $enabledTweakIds)
                TweakSectionList(sectionLabel: "Fonts & Icons", sectionIcon: "paintbrush", tweaks: fontsIcons, enabledTweakIds: $enabledTweakIds)
                TweakSectionList(sectionLabel: "Control Center", sectionIcon: "square.grid.2x2", tweaks: controlCenter, enabledTweakIds: $enabledTweakIds)
                TweakSectionList(sectionLabel: "Sound Effects", sectionIcon: "speaker.wave.2", tweaks: soundEffects, enabledTweakIds: $enabledTweakIds)
                if weOnADebugBuild || showRiskyTweaks {
                    TweakSectionList(sectionLabel: "Risky Tweaks", sectionIcon: "exclamationmark.triangle", tweaks: riskyTweaks, isRiskyTweak: true, enabledTweakIds: $enabledTweakIds)
                }
            }
            .listStyle(.plain)
            .navigationTitle("dirtyZero")
            .safeAreaInset(edge: .bottom) {
                OverlayButtonContainer(content: VStack {
                    Button(action: {
                        Haptic.shared.play(.heavy)
                        if enabledTweaks.isEmpty {
                            Alertinator.shared.alert(title: "No tweaks were selected!", body: "Select some tweaks first, then try again.")
                        } else {
                            applyTweaks(tweaks: enabledTweaks)
                        }
                    }) {
                        ButtonLabel(text: "Apply Tweaks", icon: "checkmark")
                    }
                    .buttonStyle(GlassyButtonStyle(color: enabledTweaks.isEmpty ? .gray : .green, isMaterialButton: true))
                    HStack {
                        Button(action: {
                            Haptic.shared.play(.soft)
                            Alertinator.shared.alert(title: "Warning!", body: "To revert all tweaks currently applied, we'll have to reboot your device.", actionLabel: "Reboot", action: {
                                try? zeroPoC(path: "/usr/lib/dyld")
                            })
                        }) {
                            ButtonLabel(text: "Remove", icon: "xmark")
                        }
                        .buttonStyle(GlassyButtonStyle(color: .red, isMaterialButton: true))
                        Button(action: {
                            Haptic.shared.play(.heavy)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                if isDatAppInstalled(respringAppBID) {
                                    LSApplicationWorkspace.default().openApplication(withBundleID: respringAppBID)
                                } else {
                                    Alertinator.shared.alert(title: "RespringApp Not Detected", body: "Make sure you have RespringApp installed, then try again.")
                                }
                            }
                        }) {
                            ButtonLabel(text: "Respring", icon: "goforward")
                        }
                        .buttonStyle(GlassyButtonStyle(color: .orange, isMaterialButton: true))
                    }
                })
            }
            .onAppear {
                if weOnADebugBuild {
                    print("[!] We're on a debug build!")
                }
                if !hasShownWelcome {
                    print("[*] Welcome to dirtyZero!\n[*] Running on \(device.systemName!) \(device.systemVersion!), \(device.description)\n[!] All tweaks are done in memory, so if something goes wrong, you can force reboot to revert changes.")
                    hasShownWelcome = true
                }
                if !isdirtyZeroSupported() && !weOnADebugBuild {
                    Alertinator.shared.alert(title: "Warning!", body: "This version of iOS does not and never will support dirtyZero.", showCancel: false, actionLabel: "Exit App", action: {
                        exitinator()
                    })
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        showSettingsPopover = true
                    }) {
                        Image(systemName: "gearshape")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        showCustomTweaksPopover = true
                    }) {
                        Image(systemName: "paintpalette")
                    }
                }
            }
            .sheet(isPresented: $showSettingsPopover) {
                SettingsView()
            }
            .sheet(isPresented: $showCustomTweaksPopover) {
                CustomTweaksView()
            }
        }
    }
    
    // MARK: Functions
    func applyTweaks(tweaks: [ZeroTweak]) {
        var applyingString = "[*] Applying the selected tweaks: "
        let tweakNames = enabledTweaks.map { $0.name }.joined(separator: ", ")
        applyingString += tweakNames
        
        print(applyingString)
        
        let totalTweaks = enabledTweaks.count
        var currentTweak = 1
        
        do {
            for tweak in enabledTweaks {
                applyingString = "[\(currentTweak)/\(totalTweaks)] Applying \(tweak.name)..."
                print(applyingString)
                for path in tweak.paths {
                    try zeroPoC(path: path)
                }
                print("[*] Applied tweak \(currentTweak)/\(totalTweaks)!")
                currentTweak += 1
                tweakApplicationStatus = .applying
            }
            print("[*] Successfully applied all tweaks!")
            Alertinator.shared.alert(title: "Tweaks Applied Successfully!", body: "\(totalTweaks)/\(totalTweaks) tweaks applied! If you'd like to respring, ensure you have RespringApp installed.")
            tweakApplicationStatus = .applied
            appliedString = "\(totalTweaks)/\(totalTweaks) tweaks applied! If you'd like to respring, ensure you have RespringApp installed."
        } catch {
            tweakApplicationStatus = .failed
            failedString = "There was an error while applying tweak \(currentTweak)/\(totalTweaks): \(error)."
            print("[!] \(error)")
            Alertinator.shared.alert(title: "Failed to Apply", body: failedString)
            return
        }
    }
    
    // the super useful "sandbox escape" that only tells you what apps are installed :fire:
    func isDatAppInstalled(_ bundleID: String) -> Bool {
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
        
        print("[*] here comes the super secret trollstore detector \"sandbox escape\" app store edition")
        let sbsFunction = unsafeBitCast(sbsAddr, to: SBSLaunchFunction.self)
        
        let result = sbsFunction(bundleID, nil, nil, nil, true)
        
        return result == 9
    }
}

#Preview {
    ContentView()
}
