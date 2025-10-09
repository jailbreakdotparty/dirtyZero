//
//  ContentView.swift
//  dirtyZero
//
//  Created by Skadz on 5/8/25.
//

import SwiftUI
import DeviceKit
import UIKit

struct ZeroTweak: Identifiable, Codable {
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

struct ContentView: View {
    let device = Device.current
    @AppStorage("enabledTweaks") private var enabledTweakIds: [String] = []
    
    @State private var hasShownWelcome = false
    @State private var customZeroPath: String = ""
    @State private var addedCustomPaths: [String] = []
    @State private var isSupported: Bool = true
    @State private var showSettingsPopover: Bool = false
    @State private var tweakApplicationStatus: String = "Ready to Apply"
    
    @FocusState private var isCustomPathFieldFocused: Bool
    
    @AppStorage("showLogs") private var showLogs: Bool = true
    @AppStorage("showDebugSettings") private var showDebugSettings: Bool = false
    @AppStorage("showRiskyTweaks") private var showRiskyTweaks: Bool = false
    
    private var tweaks: [ZeroTweak] {
        homeScreen + lockScreen + alertsOverlays + fontsIcons + controlCenter + soundEffects + riskyTweaks
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
        ZStack(alignment: .bottom) {
            NavigationStack {
                List {
                    VStack(alignment: .leading, spacing: 20) {
                        if isSupported || weOnADebugBuild {
                            Section(header: HStack {
                                Image(systemName: "info.circle")
                                Text("Version \(UIApplication.appVersion!) (\(weOnADebugBuild ? "Debug" : "Release"))")
                            }.opacity(0.6).fontWeight(.semibold)) {
                                VStack {
                                    VStack {
                                        VStack(alignment: .leading) {
                                            HStack {
                                                VStack(alignment: .leading) {
                                                    HStack {
                                                        HStack {
                                                            if tweakApplicationStatus == "Applying Tweaks..." {
                                                                ProgressView()
                                                            } else if tweakApplicationStatus == "Failed to Apply" {
                                                                Image(systemName: "xmark.circle.fill")
                                                                    .foregroundStyle(.red)
                                                            } else if tweakApplicationStatus == "Ready to Apply" {
                                                                Image(systemName: "checkmark.circle.fill")
                                                                    .opacity(0.6)
                                                            } else {
                                                                Image(systemName: "checkmark.circle.fill")
                                                                    .foregroundStyle(.green)
                                                            }
                                                            Text(tweakApplicationStatus)
                                                        }
                                                    }
                                                }
                                                .fontWeight(.medium)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                            }
                                        }
                                        VStack {
                                            if showLogs {
                                                ZStack(alignment: .top) {
                                                    LogView()
                                                        .frame(maxWidth: .infinity)
                                                    VStack {
                                                        Rectangle()
                                                            .fill(
                                                                LinearGradient(
                                                                    gradient: Gradient(colors: [
                                                                        Color(.tertiarySystemBackground).opacity(0.9),
                                                                        Color.clear
                                                                    ]),
                                                                    startPoint: .top,
                                                                    endPoint: .bottom
                                                                )
                                                            )
                                                            .frame(height: 20)
                                                        Spacer()
                                                        Rectangle()
                                                            .fill(
                                                                LinearGradient(
                                                                    gradient: Gradient(colors: [
                                                                        Color.clear,
                                                                        Color(.tertiarySystemBackground).opacity(0.9),
                                                                    ]),
                                                                    startPoint: .top,
                                                                    endPoint: .bottom
                                                                )
                                                            )
                                                            .frame(height: 20)
                                                    }
                                                    .frame(alignment: .top)
                                                }
                                                .frame(height: 250)
                                                .onAppear(perform: {
                                                    if !hasShownWelcome {
                                                        print("[*] Welcome to dirtyZero!\n[*] Running on \(device.systemName!) \(device.systemVersion!), \(device.description)\n[!] All tweaks are done in memory, so if something goes wrong, you can force reboot to revert changes.")
                                                        hasShownWelcome = true
                                                    }
                                                })
                                                .padding(.horizontal)
                                                .background(Color(.tertiarySystemBackground))
                                                .cornerRadius(14)
                                            }
                                        }
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(14)
                                    .background(Color(.secondarySystemBackground))
                                    .cornerRadius(14)
                                    HStack {
                                        HStack {
                                            Image(systemName: "iphone.gen2")
                                                .frame(width: 20, height: 20)
                                            Text("\(device.systemName!) \(device.systemVersion!)")
                                        }
                                        .frame(maxWidth: .infinity, alignment: .center)
                                        .padding(10)
                                        .background(Color(.secondarySystemBackground))
                                        .cornerRadius(12)
                                        
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
                                        .background(Color(.secondarySystemBackground))
                                        .cornerRadius(14)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    VStack(alignment: .leading) {
                                        Text("Made with love by the [jailbreak.party](https://jailbreak.party/) team.\n[Join the jailbreak.party Discord!](https://jailbreak.party/discord)")
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .font(.footnote)
                                }
                                .listRowInsets(EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16))
                            }
                        }
                    }
                    VStack(alignment: .leading, spacing: 20) {
                        if isSupported || weOnADebugBuild {
                            if weOnADebugBuild || showDebugSettings {
                                Section(header: HStack {
                                    Image(systemName: "ant")
                                    Text("Debugging")
                                }.opacity(0.6).fontWeight(.semibold)) {
                                    VStack {
                                        HStack {
                                            TextField("Custom Path", text: $customZeroPath, axis: .vertical)
                                                .padding(13)
                                                .frame(maxWidth: .infinity)
                                                .background(.accent.opacity(0.2))
                                                .cornerRadius(12)
                                                .foregroundStyle(.accent)
                                                .focused($isCustomPathFieldFocused)
                                            if isCustomPathFieldFocused {
                                                RegularButtonStyle(text: "", icon: "xmark", useMaxHeight: false, disabled: false, foregroundStyle: .red, action: {
                                                    isCustomPathFieldFocused = false
                                                }).frame(width: 50)
                                            } else {
                                                RegularButtonStyle(text: "", icon: "checkmark", useMaxHeight: false, disabled: false, foregroundStyle: .green, action: {
                                                    if customZeroPath.isEmpty {
                                                        Alertinator.shared.alert(title: "Invaild Path", body: "Please enter a vaild path.")
                                                    } else {
                                                        try? zeroPoC(path: customZeroPath)
                                                        Alertinator.shared.alert(title: "Attempted to Zero", body: "Attempted to zero out \(customZeroPath)")
                                                    }
                                                }).frame(width: 50)
                                                RegularButtonStyle(text: "", icon: "doc.on.clipboard", useMaxHeight: false, disabled: false, foregroundStyle: .accent, action: {
                                                    if let clipboardText = UIPasteboard.general.string {
                                                        customZeroPath = clipboardText
                                                    } else {
                                                        print("[!] epic pasteboard fail :fire:")
                                                    }
                                                }).frame(width: 50)
                                            }
                                        }
                                        RegularButtonStyle(text: "Print Debug Info", icon: "ant.fill", useMaxHeight: false, disabled: false, foregroundStyle: .accent, action: {
                                            print("[*] enabledTweakIds: \(enabledTweakIds)\n[*] isSupported: \(isSupported)\n[*] weOnADebugBuild: \(weOnADebugBuild)")
                                        })
                                    }
                                    .listRowInsets(EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16))
                                }
                            }
                            TweakSectionList(sectionLabel: "Home Screen", sectionIcon: "house", tweaks: homeScreen, enabledTweakIds: $enabledTweakIds)
                            TweakSectionList(sectionLabel: "Lock Screen", sectionIcon: "lock", tweaks: lockScreen, enabledTweakIds: $enabledTweakIds)
                            TweakSectionList(sectionLabel: "Alerts & Overlays", sectionIcon: "exclamationmark.triangle", tweaks: alertsOverlays, enabledTweakIds: $enabledTweakIds)
                            TweakSectionList(sectionLabel: "Fonts & Icons", sectionIcon: "paintbrush", tweaks: fontsIcons, enabledTweakIds: $enabledTweakIds)
                            TweakSectionList(sectionLabel: "Control Center", sectionIcon: "square.grid.2x2", tweaks: controlCenter, enabledTweakIds: $enabledTweakIds)
                            TweakSectionList(sectionLabel: "Sound Effects", sectionIcon: "speaker.wave.2", tweaks: soundEffects, enabledTweakIds: $enabledTweakIds)
                            if weOnADebugBuild || showRiskyTweaks {
                                TweakSectionList(sectionLabel: "Risky Tweaks", sectionIcon: "exclamationmark.triangle", tweaks: riskyTweaks, enabledTweakIds: $enabledTweakIds)
                            }
                        } else {
                            // this too will make people who can't read cry
                            VStack {
                                Image(systemName: "iphone.slash")
                                    .foregroundStyle(.secondary)
                                    .font(.system(size: 40).weight(.regular))
                                    .imageScale(.large)
                                
                                Text("**Unsupported Version**")
                                    .multilineTextAlignment(.center)
                                    .font(.title2)
                                Text("Your current software version (\(device.systemVersion!)) is not and never will be supported by dirtyZero.\nYou also cannot downgrade to a supported version.")
                                    .multilineTextAlignment(.center)
                                    .font(.system(size: 16))
                                    .foregroundStyle(.secondary)
                                
                                RegularButtonStyle(text: "Exit App", icon: "xmark", useMaxHeight: false, disabled: false, foregroundStyle: .red, action: {
                                    exitinator()
                                })
                            }
                        }
                    }
                    .navigationTitle("dirtyZero")
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading, content: {
                            Button(action: {
                                showSettingsPopover = true
                            }) {
                                Image(systemName: "gearshape")
                            }
                        })
                    }
                    // this will make people who cannot read cry.
                    .onAppear {
                        let doubleSystemVersion = Double(device.systemVersion!.split(separator: ".").prefix(2).joined(separator: "."))!
                        if doubleSystemVersion >= 18.4 && !weOnADebugBuild {
                            isSupported = false
                        }
                    }
                    .popover(isPresented: $showSettingsPopover, content: {
                        SettingsView(showDebugSettings: $showDebugSettings, showLogs: $showLogs, showRiskyTweaks: $showRiskyTweaks, hasShownWelcome: $hasShownWelcome)
                    })
                }
                .listStyle(.plain)
                .safeAreaInset(edge: .bottom) {
                    VStack {
                        if enabledTweaks.isEmpty {
                            RegularButtonStyle(text: "Apply Tweaks", icon: "checkmark", useMaxHeight: false, disabled: !isSupported, foregroundStyle: .gray, action: {
                                Alertinator.shared.alert(title: "No Tweaks Enabled!", body: "Please select some tweaks first.")
                            })
                        } else {
                            RegularButtonStyle(text: "Apply Tweaks", icon: "checkmark", useMaxHeight: false, disabled: !isSupported, foregroundStyle: .green, action: {
                                applyTweaks(tweaks: enabledTweaks)
                            })
                        }
                        
                        HStack {
                            RegularButtonStyle(text: "Revert", icon: "xmark", useMaxHeight: false, disabled: !isSupported, foregroundStyle: .red, action: {
                                Alertinator.shared.alert(title: "Device Will Reboot", body: "Your device will have to reboot in order to revert all tweaks. Tap OK to continue.", action: {
                                    try? zeroPoC(path: "/usr/lib/dyld")
                                })
                            })
                            
                            RegularButtonStyle(text: "Respring", icon: "arrow.counterclockwise", useMaxHeight: false, disabled: !isSupported, foregroundStyle: .orange, action: {
                                let respringBundleID = "com.respring.app"
                                if isDatAppInstalled(respringBundleID) {
                                    LSApplicationWorkspace.default().openApplication(withBundleID: respringBundleID)
                                } else {
                                    Alertinator.shared.alert(title: "RespringApp Not Detected", body: "Make sure you have RespringApp installed, then try again.")
                                }
                            })
                        }
                    }
                    .contextMenu {
                        Button {
                            Alertinator.shared.prompt(title: "Custom Path", placeholder: "Path") { path in
                                if let _ = path, !path!.isEmpty {
                                    try? zeroPoC(path: path!)
                                } else {
                                    Alertinator.shared.alert(title: "Invalid Path", body: "Enter a vaild path.")
                                }
                            }
                        } label: {
                            Label("Custom Path", systemImage: "apple.terminal")
                        }
                        .disabled(!isSupported)
                        
                        Button {
                            try? zeroPoC(path: "/usr/lib/dyld")
                        } label: {
                            Label("Panic", systemImage: "ant")
                        }
                        .disabled(!isSupported)
                    }
                    .padding(.horizontal, 25)
                    .padding(.top, 70)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.clear,
                                Color(.systemBackground).opacity(0.85)
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                }
            }
        }
    }
    
    func applyTweaks(tweaks: [ZeroTweak]) {
        var applyingString = "[*] Applying the selected tweaks: "
        let tweakNames = enabledTweaks.map { $0.name }.joined(separator: ", ")
        applyingString += tweakNames
        
        print(applyingString)
        
        let totalTweaks = enabledTweaks.count
        var currentTweak = 1
        
        do {
            for tweak in enabledTweaks {
                print("[\(currentTweak)/\(totalTweaks)] Applying \(tweak.name)...")
                for path in tweak.paths {
                    try zeroPoC(path: path)
                }
                print("[*] Applied tweak \(currentTweak)/\(totalTweaks)!")
                currentTweak += 1
                tweakApplicationStatus = "Applying Tweaks..."
            }
            print("[*] Successfully applied all tweaks!")
            Alertinator.shared.alert(title: "Tweaks Applied Successfully!", body: "\(totalTweaks)/\(totalTweaks) tweaks applied! If you'd like to respring, ensure you have RespringApp installed.")
            tweakApplicationStatus = "Applied Tweaks"
        } catch {
            tweakApplicationStatus = "Failed to Apply"
            print("[!] \(error)")
            Alertinator.shared.alert(title: "Failed to Apply", body: "There was an error while applying tweak \(currentTweak)/\(totalTweaks): \(error).")
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
