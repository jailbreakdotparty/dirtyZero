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

var homeScreen: [ZeroTweak] = [
    ZeroTweak(icon: "dock.rectangle", name: "Disable Dock Background", minSupportedVersion: 16.0, maxSupportedVersion: 18.9, paths: ["/System/Library/PrivateFrameworks/CoreMaterial.framework/dockDark.materialrecipe", "/System/Library/PrivateFrameworks/CoreMaterial.framework/dockLight.materialrecipe"]),
    ZeroTweak(icon: "folder", name: "Disable Folder Backgrounds", minSupportedVersion: 16.0, maxSupportedVersion: 18.9, paths: ["/System/Library/PrivateFrameworks/SpringBoardHome.framework/folderDark.materialrecipe", "/System/Library/PrivateFrameworks/SpringBoardHome.framework/folderLight.materialrecipe"]),
    ZeroTweak(icon: "square.text.square", name: "Disable Widget Config BG", minSupportedVersion: 16.0, maxSupportedVersion: 18.9, paths: ["/System/Library/PrivateFrameworks/SpringBoardHome.framework/stackConfigurationBackground.materialrecipe", "/System/Library/PrivateFrameworks/SpringBoardHome.framework/stackConfigurationForeground.materialrecipe"]),
    ZeroTweak(icon: "square.dashed", name: "Disable App Library BG", minSupportedVersion: 18.0, maxSupportedVersion: 18.9, paths: ["/System/Library/PrivateFrameworks/SpringBoardHome.framework/coplanarLeadingTrailingBackgroundBlur.materialrecipe"]),
    ZeroTweak(icon: "magnifyingglass", name: "Disable Library Search BG", minSupportedVersion: 18.0, maxSupportedVersion: 18.9, paths: ["/System/Library/PrivateFrameworks/SpringBoardHome.framework/homeScreenOverlay.materialrecipe"]),
    ZeroTweak(icon: "rectangle.and.text.magnifyingglass", name: "Disable Spotlight Background", minSupportedVersion: 16.0, maxSupportedVersion: 18.9, paths: ["/System/Library/PrivateFrameworks/SpringBoardHome.framework/knowledgeBackgroundDarkZoomed.descendantrecipe", "/System/Library/PrivateFrameworks/SpringBoardHome.framework/knowledgeBackgroundZoomed.descendantrecipe"]),
]

var lockScreen: [ZeroTweak] = [
    ZeroTweak(icon: "ellipsis.rectangle", name: "Disable Passcode Background", minSupportedVersion: 16.0, maxSupportedVersion: 18.9, paths: ["/System/Library/PrivateFrameworks/CoverSheet.framework/dashBoardPasscodeBackground.materialrecipe"]),
    ZeroTweak(icon: "lock", name: "Disable Lock Icon", minSupportedVersion: 16.0, maxSupportedVersion: 18.9, paths: ["/System/Library/PrivateFrameworks/SpringBoardUIServices.framework/lock@2x-812h.ca/main.caml", "/System/Library/PrivateFrameworks/SpringBoardUIServices.framework/lock@2x-896h.ca/main.caml", "/System/Library/PrivateFrameworks/SpringBoardUIServices.framework/lock@3x-812h.ca/main.caml", "/System/Library/PrivateFrameworks/SpringBoardUIServices.framework/lock@3x-896h.ca/main.caml", "/System/Library/PrivateFrameworks/SpringBoardUIServices.framework/lock@3x-d73.ca/main.caml"]),
    ZeroTweak(icon: "flashlight.off.fill", name: "Disable Quick Action Icons", minSupportedVersion: 16.0, maxSupportedVersion: 17.9, paths: ["/System/Library/PrivateFrameworks/CoverSheet.framework/Assets.car"]),
    ZeroTweak(icon: "bolt", name: "Disable Large Battery Icon", minSupportedVersion: 18.0, maxSupportedVersion: 18.9, paths: ["/System/Library/PrivateFrameworks/CoverSheet.framework/Assets.car"])
]

var alertsOverlays: [ZeroTweak] = [
    ZeroTweak(icon: "platter.filled.top.iphone", name: "Disable Notification & Widget BGs", minSupportedVersion: 16.0, maxSupportedVersion: 18.9, paths: ["/System/Library/PrivateFrameworks/CoreMaterial.framework/platterStrokeLight.visualstyleset", "/System/Library/PrivateFrameworks/CoreMaterial.framework/platterStrokeDark.visualstyleset", "/System/Library/PrivateFrameworks/CoreMaterial.framework/plattersDark.materialrecipe", "/System/Library/PrivateFrameworks/CoreMaterial.framework/platters.materialrecipe", "/System/Library/PrivateFrameworks/UserNotificationsUIKit.framework/stackDimmingLight.visualstyleset", "/System/Library/PrivateFrameworks/UserNotificationsUIKit.framework/stackDimmingDark.visualstyleset"]),
    ZeroTweak(icon: "paintpalette.fill", name: "Recolor Notifcation Shadows", minSupportedVersion: 16.0, maxSupportedVersion: 18.9, paths: [
        "/System/Library/PrivateFrameworks/PlatterKit.framework/platterVibrantShadowLight.visualstyleset", "/System/Library/PrivateFrameworks/PlatterKit.framework/platterVibrantShadowDark.visualstyleset"]),
    ZeroTweak(icon: "list.bullet.rectangle", name: "Disable Touch & Alert Backgrounds", minSupportedVersion: 16.0, maxSupportedVersion: 18.9, paths: ["/System/Library/PrivateFrameworks/CoreMaterial.framework/platformContentDark.materialrecipe", "/System/Library/PrivateFrameworks/CoreMaterial.framework/platformContentLight.materialrecipe"]),
    ZeroTweak(icon: "line.3.horizontal", name: "Disable Home Bar", minSupportedVersion: 16.0, maxSupportedVersion: 18.9, paths: ["/System/Library/PrivateFrameworks/MaterialKit.framework/Assets.car"]),
    ZeroTweak(icon: "text.rectangle.page", name: "Disable Glassy Overlays", minSupportedVersion: 16.0, maxSupportedVersion: 18.9, paths: ["/System/Library/PrivateFrameworks/CoreMaterial.framework/platformChromeDark.materialrecipe", "/System/Library/PrivateFrameworks/CoreMaterial.framework/platformChromeLight.materialrecipe"]),
    ZeroTweak(icon: "exclamationmark.triangle.fill", name: "Disable ALL Banners", minSupportedVersion: 16.0, maxSupportedVersion: 18.9, paths: ["/System/Library/PrivateFrameworks/SpringBoard.framework/BannersAuthorizedBundleIDs.plist"]),
]

var fontsIcons: [ZeroTweak] = [
    ZeroTweak(icon: "character.cursor.ibeam", name: "Enable Helvetica Font", minSupportedVersion: 16.0, maxSupportedVersion: 16.9, paths: ["/System/Library/Fonts/CoreUI/SFUI.ttf"]), //for some reason 16 stores SFUI.ttf in coreui instead of core, fuck you tim apple
    ZeroTweak(icon: "character.cursor.ibeam", name: "Enable Helvetica Font", minSupportedVersion: 17.0, maxSupportedVersion: 18.9, paths: ["/System/Library/Fonts/Core/SFUI.ttf"]),
    ZeroTweak(icon: "circle.slash", name: "Disable Emojis", minSupportedVersion: 16.0, maxSupportedVersion: 18.9, paths: ["/System/Library/Fonts/CoreAddition/AppleColorEmoji-160px.ttc"]),
    ZeroTweak(icon: "sun.max", name: "Disable Slider Icons ", minSupportedVersion: 16.0, maxSupportedVersion: 17.9, paths: ["/System/Library/ControlCenter/Bundles/DisplayModule.bundle/Brightness.ca/index.xml", "/System/Library/PrivateFrameworks/MediaControls.framework/Volume.ca/index.xml"]),
    ZeroTweak(icon: "sun.max", name: "Disable Slider Icons", minSupportedVersion: 18.0, maxSupportedVersion: 18.9, paths: ["/System/Library/ControlCenter/Bundles/DisplayModule.bundle/Brightness.ca/index.xml", "/System/Library/PrivateFrameworks/MediaControls.framework/VolumeSemibold.ca/index.xml"]),
    ZeroTweak(icon: "bell.slash", name: "Disable Ring Animation", minSupportedVersion: 16.0, maxSupportedVersion: 18.9, paths: ["/System/Library/PrivateFrameworks/SpringBoard.framework/Ringer-Leading-D73.ca/main.caml"]),
    ZeroTweak(icon: "link", name: "Disable Tethering Graphic", minSupportedVersion: 16.0, maxSupportedVersion: 18.9, paths: ["/System/Library/PrivateFrameworks/SpringBoard.framework/Tethering-D73.ca/main.caml"]),
]

var controlCenter: [ZeroTweak] = [
    ZeroTweak(icon: "square.dashed", name: "Disable CC Background", minSupportedVersion: 16.0, maxSupportedVersion: 18.9, paths: ["/System/Library/PrivateFrameworks/CoreMaterial.framework/modulesBackground.materialrecipe"]),
    ZeroTweak(icon: "circle.grid.2x2", name: "Disable CC Module Background", minSupportedVersion: 18.0, maxSupportedVersion: 18.9, paths: ["/System/Library/PrivateFrameworks/CoreMaterial.framework/modulesSheer.descendantrecipe", "/System/Library/ControlCenter/Bundles/FocusUIModule.bundle/Info.plist"]),
    ZeroTweak(icon: "wifi", name: "Disable WiFi & Bluetooth Icons", minSupportedVersion: 16.0, maxSupportedVersion: 17.9, paths: ["/System/Library/ControlCenter/Bundles/ConnectivityModule.bundle/Bluetooth.ca/index.xml", "/System/Library/ControlCenter/Bundles/ConnectivityModule.bundle/WiFi.ca/index.xml"]),
    ZeroTweak(icon: "moon", name: "Disable DND Icons", minSupportedVersion: 16.0, maxSupportedVersion: 17.9, paths: ["/System/Library/PrivateFrameworks/FocusUI.framework/dnd_cg_02.ca/main.caml"]),
    ZeroTweak(icon: "rectangle.on.rectangle", name: "Disable Screen Mirroring Module", minSupportedVersion: 16.0, maxSupportedVersion: 17.9, paths: ["/System/Library/ControlCenter/Bundles/AirPlayMirroringModule.bundle/Info.plist"]),
    ZeroTweak(icon: "lock.rotation", name: "Disable Orientation Lock Module", minSupportedVersion: 16.0, maxSupportedVersion: 17.9, paths: ["/System/Library/ControlCenter/Bundles/OrientationLockModule.bundle/Info.plist"]),
    ZeroTweak(icon: "moon", name: "Disable Focus Module", minSupportedVersion: 16.0, maxSupportedVersion: 17.9, paths: ["/System/Library/ControlCenter/Bundles/FocusUIModule.bundle/Info.plist"])
]

var soundEffects: [ZeroTweak] = [
    ZeroTweak(icon: "dot.radiowaves.left.and.right", name: "Disable AirDrop Ping", minSupportedVersion: 16.0, maxSupportedVersion: 18.9, paths: ["/System/Library/Audio/UISounds/Modern/airdrop_invite.cat"]),
    ZeroTweak(icon: "bolt", name: "Disable Charge Sound", minSupportedVersion: 16.0, maxSupportedVersion: 18.9, paths: ["/System/Library/Audio/UISounds/connect_power.caf"]),
    ZeroTweak(icon: "battery.25", name: "Disable Low Battery Sound", minSupportedVersion: 16.0, maxSupportedVersion: 18.9, paths: ["/System/Library/Audio/UISounds/low_power.caf"]),
    ZeroTweak(icon: "creditcard", name: "Disable Payment Sounds", minSupportedVersion: 16.0, maxSupportedVersion: 18.9, paths: ["/System/Library/Audio/UISounds/payment_success.caf", "/System/Library/Audio/UISounds/payment_failure.caf"]),
    ZeroTweak(icon: "phone", name: "Disable Dialing Sounds", minSupportedVersion: 16.0, maxSupportedVersion: 18.9, paths: ["/System/Library/Audio/UISounds/nano/dtmf-0.caf", "/System/Library/Audio/UISounds/nano/dtmf-1.caf", "/System/Library/Audio/UISounds/nano/dtmf-2.caf", "/System/Library/Audio/UISounds/nano/dtmf-3.caf", "/System/Library/Audio/UISounds/nano/dtmf-4.caf", "/System/Library/Audio/UISounds/nano/dtmf-5.caf", "/System/Library/Audio/UISounds/nano/dtmf-6.caf", "/System/Library/Audio/UISounds/nano/dtmf-7.caf", "/System/Library/Audio/UISounds/nano/dtmf-8.caf", "/System/Library/Audio/UISounds/nano/dtmf-9.caf", "/System/Library/Audio/UISounds/nano/dtmf-pound.caf", "/System/Library/Audio/UISounds/nano/dtmf-star.caf"])
]

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
    
    private var tweaks: [ZeroTweak] {
        homeScreen + lockScreen + alertsOverlays + fontsIcons + controlCenter + soundEffects
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
                VStack {
                    List {
                        if isSupported || weOnADebugBuild {
                            Section(header: HStack {
                                Image(systemName: "info.circle")
                                Text("Version \(UIApplication.appVersion!) (\(weOnADebugBuild ? "Debug" : "Release"))")
                            }) {
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
                                            Image(systemName: "iphone")
                                                .frame(width: 20, height: 20)
                                            Text("\(device.systemName!) \(device.systemVersion!)")
                                        }
                                        .frame(maxWidth: .infinity, alignment: .center)
                                        .padding(10)
                                        .background(Color(.secondarySystemBackground))
                                        .cornerRadius(12)
                                        
                                        HStack {
                                            Image(systemName: "hammer")
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
                            if weOnADebugBuild || showDebugSettings {
                                Section(header: HStack {
                                    Image(systemName: "ant")
                                    Text("Debugging")
                                }) {
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
                            VStack(alignment: .leading) {
                                Text("**WARNING:** If you do choose to disable all banners, this may break key system interactions.")
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .font(.footnote).opacity(0.6)
                            TweakSectionList(sectionLabel: "Fonts & Icons", sectionIcon: "paintbrush", tweaks: fontsIcons, enabledTweakIds: $enabledTweakIds)
                            TweakSectionList(sectionLabel: "Control Center", sectionIcon: "square.grid.2x2", tweaks: controlCenter, enabledTweakIds: $enabledTweakIds)
                            TweakSectionList(sectionLabel: "Sound Effects", sectionIcon: "speaker.wave.2", tweaks: soundEffects, enabledTweakIds: $enabledTweakIds)
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
                .navigationTitle("dirtyZero")
                .toolbar {
                    ToolbarItem(placement: .topBarLeading, content: {
                        Button(action: {
                            showSettingsPopover = true
                        }) {
                            Image(systemName: "gearshape.fill")
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
                    NavigationStack {
                        List {
                            Toggle("Show Debug Settings", isOn: $showDebugSettings)
                            if #available(iOS 17.0, *) {
                                Toggle("Show Logs", isOn: $showLogs)
                                    .onChange(of: showLogs) {
                                        hasShownWelcome = false
                                    }
                            } else {
                                Toggle("Show Logs", isOn: $showLogs)
                            }
                        }
                        .navigationTitle("Settings")
                    }
                })
            }
        }
    }
    
    // this talks to the thing that will eventually exploit.
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
            Alertinator.shared.alert(title: "Tweaks Applied Successfully!", body: "\(currentTweak)/\(totalTweaks) tweaks applied! If you'd like to respring, ensure you have RespringApp installed.")
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

// i skidded this stuff from cowabunga, sorry lemin.
struct MaterialView: UIViewRepresentable {
    let material: UIBlurEffect.Style
    
    init(_ material: UIBlurEffect.Style) {
        self.material = material
    }
    
    func makeUIView(context: Context) -> UIVisualEffectView {
        UIVisualEffectView(effect: UIBlurEffect(style: material))
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = UIBlurEffect(style: material)
    }
}

// i love the thing i did here. skadz does not. -lunginspector
struct TweakSectionList: View {
    let sectionLabel: String
    let sectionIcon: String
    let tweaks: [ZeroTweak]
    @Binding var enabledTweakIds: [String]
    
    let device = Device.current
    
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
        Section(header: HStack {
            Image(systemName: sectionIcon)
            Text(sectionLabel)
        }) {
            VStack {
                ForEach(tweaks) { tweak in
                    let doubleSystemVersion = Double(device.systemVersion!.split(separator: ".").prefix(2).joined(separator: "."))!
                    
                    if doubleSystemVersion <= tweak.maxSupportedVersion && doubleSystemVersion >= tweak.minSupportedVersion || weOnADebugBuild {
                        Button(action: {
                            Haptic.shared.play(.soft)
                            toggleTweak(tweak)
                        }) {
                            HStack {
                                Image(systemName: tweak.icon)
                                    .frame(width: 24, alignment: .center)
                                    .foregroundStyle(.accent)
                                Text(tweak.name)
                                    .lineLimit(1)
                                    .scaledToFit()
                                    .foregroundStyle(.accent)
                                Spacer()
                                if isTweakEnabled(tweak) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(.accent)
                                        .imageScale(.medium)
                                } else {
                                    Image(systemName: "circle")
                                        .foregroundStyle(.accent)
                                        .imageScale(.medium)
                                }
                            }
                        }
                        .buttonStyle(ListButtonStyle(color: isTweakEnabled(tweak) ? .accent : .accent.opacity(0.7), fullWidth: false))
                    }
                }
            }
            .listRowInsets(EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16))
        }
    }
}

// buttons :fire:
struct RegularButtonStyle: View {
    let text: String
    let icon: String
    let useMaxHeight: Bool
    let disabled: Bool
    let foregroundStyle: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            Haptic.shared.play(.soft)
            if !disabled {
                action()
            }
        }) {
            HStack {
                Image(systemName: icon)
                    .frame(minWidth: 22, minHeight: 22)
                if text.isEmpty {
                    
                } else {
                    Text(text)
                }
            }
        }
        .padding(.vertical, 13)
        .frame(maxWidth: .infinity, maxHeight: useMaxHeight ? .infinity : nil)
        .background(disabled ? .gray.opacity(0.4) : foregroundStyle.opacity(0.2))
        .background(.ultraThinMaterial)
        .cornerRadius(14)
        .foregroundStyle(disabled ? .gray : foregroundStyle)
        .buttonStyle(.plain)
        .opacity(disabled ? 0.8 : 1)
    }
}

// why doesn't this also have a fun comment too. anyways, skadz wrote this one. it's... alright.
struct ListButtonStyle: ButtonStyle {
    var color: Color
    var material: UIBlurEffect.Style?
    var fullWidth: Bool = false
    
    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            if fullWidth {
                configuration.label
                    .padding(14)
                    .frame(maxWidth: .infinity)
                    .background(material == nil ? AnyView(color.opacity(0.2)) : AnyView(MaterialView(material!)))
                    .cornerRadius(14)
                    .foregroundStyle(color)
            } else {
                configuration.label
                    .padding(14)
                    .frame(maxWidth: .infinity)
                    .background(material == nil ? AnyView(color.opacity(0.2)) : AnyView(MaterialView(material!)))
                    .cornerRadius(14)
                    .foregroundStyle(color)
            }
        }
    }
    
    init(color: Color = .blue, fullWidth: Bool = false) {
        self.color = color
        self.fullWidth = fullWidth
    }
    init(color: Color = .blue, material: UIBlurEffect.Style, fullWidth: Bool = false) {
        self.color = color
        self.material = material
        self.fullWidth = fullWidth
    }
}

#Preview {
    ContentView()
}
