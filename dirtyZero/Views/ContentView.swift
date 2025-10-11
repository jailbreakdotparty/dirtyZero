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
                    VStack(alignment: .leading) {
                        if isSupported || weOnADebugBuild {
                            Section(header: HeaderStyle(label: "Version \(UIApplication.appVersion!) (\(weOnADebugBuild ? "Debug" : "Release"))", icon: "info.circle")) {
                                VStack {
                                    VStack {
                                        VStack(alignment: .leading) {
                                            HStack {
                                                VStack(alignment: .leading) {
                                                    HStack {
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
                                                        .padding(.horizontal)
                                                    VStack {
                                                        VariableBlurView(maxBlurRadius: 1, direction: .blurredTopClearBottom)
                                                            .frame(maxHeight: 20)
                                                        Spacer()
                                                        VariableBlurView(maxBlurRadius: 1, direction: .blurredBottomClearTop)
                                                            .frame(maxHeight: 20)
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
                                                .background(Color(.tertiarySystemBackground))
                                                .cornerRadius(12)
                                            } else {
                                                Text(tweakApplicationStatus.description)
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                    .font(.body)
                                                    .multilineTextAlignment(.leading)
                                                    .opacity(0.8)
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
                                    Text("Made with love by the [jailbreak.party](https://jailbreak.party/) team.\n[Join the jailbreak.party Discord!](https://jailbreak.party/discord)")
                                        .font(.system(.footnote, weight: .regular))
                                        .opacity(0.8)
                                        .padding(.leading, 6)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                .listRowInsets(EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16))
                            }
                        }
                    }
                    VStack(alignment: .leading) {
                        if isSupported || weOnADebugBuild {
                            if weOnADebugBuild || showDebugSettings {
                                Section(header: HeaderStyle(label: "Debugging", icon: "ant")) {
                                    VStack {
                                        HStack {
                                            HStack(spacing: 10) {
                                                if customZeroPath.isEmpty {
                                                    Image(systemName: "terminal")
                                                        .opacity(0.25)
                                                } else {
                                                    Image(systemName: "terminal")
                                                        .foregroundStyle(.accent)
                                                }
                                                TextField("Custom Path", text: $customZeroPath, axis: .vertical)
                                                    .foregroundStyle(.accent)
                                            }
                                            .padding(13)
                                            .frame(maxWidth: .infinity)
                                            .background(.accent.opacity(0.2))
                                            .cornerRadius(12)
                                            .focused($isCustomPathFieldFocused)
                                            if isCustomPathFieldFocused {
                                                RegularButtonStyle(text: "", icon: "xmark", isPNGIcon: false, disabled: false, foregroundStyle: .red, action: {
                                                    isCustomPathFieldFocused = false
                                                }).frame(width: 50)
                                            } else {
                                                RegularButtonStyle(text: "", icon: "checkmark", isPNGIcon: false, disabled: false, foregroundStyle: .green, action: {
                                                    if customZeroPath.isEmpty {
                                                        Alertinator.shared.alert(title: "Invaild Path", body: "Please enter a vaild path.")
                                                    } else {
                                                        try? zeroPoC(path: customZeroPath)
                                                        Alertinator.shared.alert(title: "Attempted to Zero", body: "Attempted to zero out \(customZeroPath)")
                                                    }
                                                }).frame(width: 50)
                                                RegularButtonStyle(text: "", icon: "doc.on.clipboard", isPNGIcon: false, disabled: false, foregroundStyle: .accent, action: {
                                                    if let clipboardText = UIPasteboard.general.string {
                                                        customZeroPath = clipboardText
                                                    } else {
                                                        print("[!] epic pasteboard fail :fire:")
                                                    }
                                                }).frame(width: 50)
                                            }
                                        }
                                        RegularButtonStyle(text: "Print Debug Info", icon: "ant.fill", isPNGIcon: false, disabled: false, foregroundStyle: .accent, action: {
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
                                
                                RegularButtonStyle(text: "Exit App", icon: "xmark", isPNGIcon: false, disabled: false, foregroundStyle: .red, action: {
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
                        ToolbarItem(placement: .topBarTrailing, content: {
                            Button(action: {
                                showCustomTweaksPopover = true
                            }) {
                                Image(systemName: "paintbrush")
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
                    .sheet(isPresented: $showSettingsPopover, content: {
                        SettingsView()
                    })
                    .sheet(isPresented: $showCustomTweaksPopover, content: {
                        CustomTweaksView()
                    })
                }
                .listStyle(.plain)
                .safeAreaInset(edge: .bottom) {
                    VStack {
                        if enabledTweaks.isEmpty {
                            RegularButtonStyle(text: "Apply Tweaks", icon: "checkmark", isPNGIcon: false, disabled: !isSupported, foregroundStyle: .gray, action: {
                                Alertinator.shared.alert(title: "No Tweaks Enabled!", body: "Please select some tweaks first.")
                            })
                        } else {
                            RegularButtonStyle(text: "Apply Tweaks", icon: "checkmark", isPNGIcon: false, disabled: !isSupported, foregroundStyle: .green, action: {
                                applyTweaks(tweaks: enabledTweaks)
                            })
                        }
                        
                        HStack {
                            RegularButtonStyle(text: "Revert", icon: "xmark", isPNGIcon: false, disabled: !isSupported, foregroundStyle: .red, action: {
                                Alertinator.shared.alert(title: "Device Will Reboot", body: "Your device will have to reboot in order to revert all tweaks. Tap OK to continue.", action: {
                                    try? zeroPoC(path: "/usr/lib/dyld")
                                })
                            })
                            
                            RegularButtonStyle(text: "Respring", icon: "arrow.counterclockwise", isPNGIcon: false, disabled: !isSupported, foregroundStyle: .orange, action: {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                    let respringBundleID = "com.respring.app"
                                    if isDatAppInstalled(respringBundleID) {
                                        LSApplicationWorkspace.default().openApplication(withBundleID: respringBundleID)
                                    } else {
                                        Alertinator.shared.alert(title: "RespringApp Not Detected", body: "Make sure you have RespringApp installed, then try again.")
                                    }
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
                            Label("Custom Path", systemImage: "terminal")
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
                    .padding(.top, 50)
                    .background(
                        ZStack {
                            Rectangle()
                                .foregroundStyle(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color.clear,
                                            Color(.systemBackground).opacity(0.7)
                                        ]),
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                            VariableBlurView(maxBlurRadius: 8, direction: .blurredBottomClearTop)
                        }
                        .ignoresSafeArea()
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
