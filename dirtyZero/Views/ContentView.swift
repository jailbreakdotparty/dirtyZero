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

var springBoard: [ZeroTweak] = [
    ZeroTweak(icon: "dock.rectangle", name: "Disable Dock Background", minSupportedVersion: 17.0, maxSupportedVersion: 18.9, paths: ["/System/Library/PrivateFrameworks/CoreMaterial.framework/dockDark.materialrecipe", "/System/Library/PrivateFrameworks/CoreMaterial.framework/dockLight.materialrecipe"]),
    ZeroTweak(icon: "folder", name: "Disable Folder Backgrounds", minSupportedVersion: 17.0, maxSupportedVersion: 18.9, paths: ["/System/Library/PrivateFrameworks/SpringBoardHome.framework/folderDark.materialrecipe", "/System/Library/PrivateFrameworks/SpringBoardHome.framework/folderLight.materialrecipe"]),
    ZeroTweak(icon: "list.bullet.rectangle", name: "Disable Alert & Touch Backgrounds", minSupportedVersion: 17.0, maxSupportedVersion: 18.9, paths: ["/System/Library/PrivateFrameworks/CoreMaterial.framework/platformContentDark.materialrecipe", "/System/Library/PrivateFrameworks/CoreMaterial.framework/platformContentLight.materialrecipe"]),
    ZeroTweak(icon: "magnifyingglass", name: "Disable Spotlight Background", minSupportedVersion: 17.0, maxSupportedVersion: 18.9, paths: ["/System/Library/PrivateFrameworks/SpringBoardHome.framework/knowledgeBackgroundDarkZoomed.descendantrecipe", "/System/Library/PrivateFrameworks/SpringBoardHome.framework/knowledgeBackgroundZoomed.descendantrecipe"]),
    ZeroTweak(icon: "square.text.square", name: "Disable Widget Config BG", minSupportedVersion: 17.0, maxSupportedVersion: 18.9, paths: ["/System/Library/PrivateFrameworks/SpringBoardHome.framework/stackConfigurationBackground.materialrecipe", "/System/Library/PrivateFrameworks/SpringBoardHome.framework/stackConfigurationForeground.materialrecipe"]),
    ZeroTweak(icon: "square.dashed", name: "Disable App Library BG", minSupportedVersion: 18.0, maxSupportedVersion: 18.9, paths: ["/System/Library/PrivateFrameworks/SpringBoardHome.framework/coplanarLeadingTrailingBackgroundBlur.materialrecipe"]),
]

var lockScreen: [ZeroTweak] = [
    ZeroTweak(icon: "ellipsis.rectangle", name: "Disable Passcode Background", minSupportedVersion: 17.0, maxSupportedVersion: 18.9, paths: ["/System/Library/PrivateFrameworks/CoverSheet.framework/dashBoardPasscodeBackground.materialrecipe"]),
    ZeroTweak(icon: "lock", name: "Disable Lock Icon", minSupportedVersion: 17.0, maxSupportedVersion: 18.9, paths: ["/System/Library/PrivateFrameworks/SpringBoardUIServices.framework/lock@2x-812h.ca/main.caml", "/System/Library/PrivateFrameworks/SpringBoardUIServices.framework/lock@2x-896h.ca/main.caml", "/System/Library/PrivateFrameworks/SpringBoardUIServices.framework/lock@3x-812h.ca/main.caml", "/System/Library/PrivateFrameworks/SpringBoardUIServices.framework/lock@3x-896h.ca/main.caml", "/System/Library/PrivateFrameworks/SpringBoardUIServices.framework/lock@3x-d73.ca/main.caml"]),
    ZeroTweak(icon: "flashlight.off.fill", name: "Disable Quick Action Icons", minSupportedVersion: 17.0, maxSupportedVersion: 17.9, paths: ["/System/Library/PrivateFrameworks/CoverSheet.framework/Assets.car"]),
    ZeroTweak(icon: "bolt", name: "Disable Large Battery Icon", minSupportedVersion: 18.0, maxSupportedVersion: 18.9, paths: ["/System/Library/PrivateFrameworks/CoverSheet.framework/Assets.car"])
]

var systemWideCustomization: [ZeroTweak] = [
    ZeroTweak(icon: "bell.slash", name: "Disable Notification & Widget BGs", minSupportedVersion: 17.0, maxSupportedVersion: 18.9, paths: ["/System/Library/PrivateFrameworks/CoreMaterial.framework/platterStrokeLight.visualstyleset", "/System/Library/PrivateFrameworks/CoreMaterial.framework/platterStrokeDark.visualstyleset", "/System/Library/PrivateFrameworks/CoreMaterial.framework/plattersDark.materialrecipe", "/System/Library/PrivateFrameworks/CoreMaterial.framework/platters.materialrecipe"]),
    ZeroTweak(icon: "line.3.horizontal", name: "Disable Home Bar", minSupportedVersion: 17.0, maxSupportedVersion: 18.9, paths: ["/System/Library/PrivateFrameworks/MaterialKit.framework/Assets.car"]),
    ZeroTweak(icon: "character.cursor.ibeam", name: "Enable Helvetica Font", minSupportedVersion: 17.0, maxSupportedVersion: 18.9, paths: ["/System/Library/Fonts/Core/SFUI.ttf"]),
    ZeroTweak(icon: "sun.max", name: "Disable Slider Icons ", minSupportedVersion: 17.0, maxSupportedVersion: 17.9, paths: ["/System/Library/ControlCenter/Bundles/DisplayModule.bundle/Brightness.ca/index.xml", "/System/Library/PrivateFrameworks/MediaControls.framework/Volume.ca/index.xml"]),
    ZeroTweak(icon: "sun.max", name: "Disable Slider Icons", minSupportedVersion: 18.0, maxSupportedVersion: 18.9, paths: ["/System/Library/ControlCenter/Bundles/DisplayModule.bundle/Brightness.ca/index.xml", "/System/Library/PrivateFrameworks/MediaControls.framework/VolumeSemibold.ca/index.xml"]),
]

var soundEffects: [ZeroTweak] = [
    ZeroTweak(icon: "dot.radiowaves.left.and.right", name: "Disable AirDrop Ping", minSupportedVersion: 17.0, maxSupportedVersion: 18.9, paths: ["/System/Library/Audio/UISounds/Modern/airdrop_invite.cat"]),
    ZeroTweak(icon: "bolt", name: "Disable Charge Sound", minSupportedVersion: 17.0, maxSupportedVersion: 18.9, paths: ["/System/Library/Audio/UISounds/connect_power.caf"]),
    ZeroTweak(icon: "battery.25", name: "Disable Low Battery Sound", minSupportedVersion: 17.0, maxSupportedVersion: 18.9, paths: ["/System/Library/Audio/UISounds/low_power.caf"]),
    ZeroTweak(icon: "creditcard", name: "Disable Payment Sounds", minSupportedVersion: 17.0, maxSupportedVersion: 18.9, paths: ["/System/Library/Audio/UISounds/payment_success.caf", "/System/Library/Audio/UISounds/payment_failure.caf"])
]

var controlCenter: [ZeroTweak] = [
    ZeroTweak(icon: "square.dashed", name: "Disable CC Background", minSupportedVersion: 17.0, maxSupportedVersion: 18.9, paths: ["/System/Library/PrivateFrameworks/CoreMaterial.framework/modulesBackground.materialrecipe"]),
    ZeroTweak(icon: "circle.grid.2x2", name: "Disable CC Module Background", minSupportedVersion: 18.0, maxSupportedVersion: 18.9, paths: ["/System/Library/PrivateFrameworks/CoreMaterial.framework/modulesSheer.descendantrecipe", "/System/Library/ControlCenter/Bundles/FocusUIModule.bundle/Info.plist"]),
    ZeroTweak(icon: "wifi", name: "Disable WiFi & Bluetooth Icons", minSupportedVersion: 17.0, maxSupportedVersion: 17.9, paths: ["/System/Library/ControlCenter/Bundles/ConnectivityModule.bundle/Bluetooth.ca/index.xml", "/System/Library/ControlCenter/Bundles/ConnectivityModule.bundle/WiFi.ca/index.xml"]),
    ZeroTweak(icon: "rectangle.on.rectangle", name: "Disable Screen Mirroring Module", minSupportedVersion: 17.0, maxSupportedVersion: 17.9, paths: ["/System/Library/ControlCenter/Bundles/AirPlayMirroringModule.bundle/Info.plist"]),
    ZeroTweak(icon: "lock.rotation", name: "Disable Orientation Lock Module", minSupportedVersion: 17.0, maxSupportedVersion: 17.9, paths: ["/System/Library/ControlCenter/Bundles/OrientationLockModule.bundle/Info.plist"]),
    ZeroTweak(icon: "moon", name: "Disable Focus Module", minSupportedVersion: 17.0, maxSupportedVersion: 17.9, paths: ["/System/Library/ControlCenter/Bundles/FocusUIModule.bundle/Info.plist"])
]

struct ContentView: View {
    let device = Device.current
    @AppStorage("enabledTweaks") private var enabledTweakIds: [String] = []
    
    @State private var hasShownWelcome = false
    @State private var customZeroPath: String = ""
    @State private var addedCustomPaths: [String] = []
    @State private var isSupported: Bool = true
    
    private var tweaks: [ZeroTweak] {
        springBoard + lockScreen + systemWideCustomization + soundEffects + controlCenter
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
                        Section(header: HStack {
                            Image(systemName: "info.circle")
                            Text("Version \(UIApplication.appVersion!) (\(weOnADebugBuild ? "Debug" : "Release"))")
                        }) {
                            VStack {
                                LogView()
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 260)
                                    .onAppear(perform: {
                                        if !hasShownWelcome {
                                            print("[*] Welcome to dirtyZero!\n[*] Running on \(device.systemName!) \(device.systemVersion!), \(device.description)\n[!] All tweaks are done in memory, so if something goes wrong, you can force reboot to revert changes.")
                                            hasShownWelcome = true
                                        }
                                    })
                                    .listRowInsets(EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16))
                                    .padding()
                                    .background(Color(.secondarySystemFill))
                                    .clipShape(.rect(cornerRadius: 14))
                                
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text("Made with love by the [jailbreak.party](https://jailbreak.party) team.\n[Join the jailbreak.party Discord!](https://discord.gg/XPj66zZ4gT)")
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .font(.footnote)
                                }
                            }
                        }
                        
                        if weOnADebugBuild {
                            Section(header: HStack {
                                Image(systemName: "ant")
                                Text("Debugging")
                            }) {
                                VStack {
                                    RegularButtonStyle(text: "Print enabledTweakIds", icon: "list.bullet", useMaxHeight: false, disabled: false, foregroundStyle: .red, action: {
                                        print(enabledTweakIds)
                                    })
                                    HStack {
                                        TextField("Custom Path", text: $customZeroPath, axis: .vertical)
                                            .padding(13)
                                            .frame(width: 250)
                                            .background(.accent.opacity(0.2))
                                            .background(.ultraThinMaterial)
                                            .cornerRadius(14)
                                            .foregroundStyle(.accent)
                                        RegularButtonStyle(text: "", icon: "arrow.up.doc", useMaxHeight: false, disabled: false, foregroundStyle: .blue, action: {
                                            if customZeroPath.isEmpty {
                                                Alertinator.shared.alert(title: "Invaild Path", body: "Please enter a vaild path.")
                                            } else {
                                                dirtyZeroHide(path: customZeroPath)
                                            }
                                        })
                                        RegularButtonStyle(text: "", icon: "doc.on.clipboard", useMaxHeight: false, disabled: false, foregroundStyle: .blue, action: {
                                            if let clipboardText = UIPasteboard.general.string {
                                                customZeroPath = clipboardText
                                            } else {
                                                print("[!] epic pasteboard fail :fire:")
                                            }
                                        })
                                    }
                                }
                            }
                        }
                        
                        if isSupported {
                            TweakSectionList(sectionLabel: "Home Screen", sectionIcon: "house", tweaks: springBoard, enabledTweakIds: $enabledTweakIds)
                            TweakSectionList(sectionLabel: "Lock Screen", sectionIcon: "lock", tweaks: lockScreen, enabledTweakIds: $enabledTweakIds)
                            TweakSectionList(sectionLabel: "Systemwide Customization", sectionIcon: "gearshape", tweaks: systemWideCustomization, enabledTweakIds: $enabledTweakIds)
                            TweakSectionList(sectionLabel: "Sound Effects", sectionIcon: "speaker.wave.2", tweaks: soundEffects, enabledTweakIds: $enabledTweakIds)
                            TweakSectionList(sectionLabel: "Control Center", sectionIcon: "square.grid.2x2", tweaks: controlCenter, enabledTweakIds: $enabledTweakIds)
                        } else {
                            VStack {
                                Image(systemName: "iphone.slash")
                                    .foregroundStyle(.secondary)
                                    .font(.system(size: 40).weight(.regular))
                                    .imageScale(.large)
                                
                                Text("**Unsupported Version**")
                                    .multilineTextAlignment(.center)
                                    .font(.title2)
                                    .foregroundStyle(.secondary)
                                Text("Your current software version (\(device.systemVersion!)) is not and never will be supported by dirtyZero.\nYou also cannot downgrade to a supported version.")
                                    .multilineTextAlignment(.center)
                                    .font(.system(size: 16))
                                    .foregroundStyle(.secondary)
                                
                                RegularButtonStyle(text: "Exit App", icon: "apps.iphone", useMaxHeight: false, disabled: false, foregroundStyle: .blue, action: {
                                    exitinator()
                                })
                            }
                        }
                    }
                    .listStyle(.plain)
                    .listRowInsets(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
                    // Bottom Buttons
                    .safeAreaInset(edge: .bottom) {
                        VStack {
                            if enabledTweaks.isEmpty {
                                RegularButtonStyle(text: "Apply Tweaks", icon: "checkmark", useMaxHeight: false, disabled: !isSupported, foregroundStyle: .gray, action: {
                                    Alertinator.shared.alert(title: "No Tweaks Enabled!", body: "Please select some tweaks first.")
                                })
                            } else {
                                RegularButtonStyle(text: "Apply Tweaks", icon: "checkmark", useMaxHeight: false, disabled: !isSupported, foregroundStyle: .green, action: {
                                    var applyingString = "[*] Applying the selected tweaks: "
                                    let tweakNames = enabledTweaks.map { $0.name }.joined(separator: ", ")
                                    applyingString += tweakNames
                                    
                                    print(applyingString)
                                    
                                    for tweak in enabledTweaks {
                                        for path in tweak.paths {
                                            dirtyZeroHide(path: path)
                                        }
                                    }
                                })
                            }
                            
                            HStack {
                                RegularButtonStyle(text: "Revert", icon: "xmark", useMaxHeight: false, disabled: !isSupported, foregroundStyle: .red, action: {
                                    Alertinator.shared.alert(title: "Device Will Reboot", body: "Your device will have to reboot in order to revert all tweaks. Tap OK to continue.", action: {
                                        dirtyZeroHide(path: "/usr/lib/dyld")
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
                                        dirtyZeroHide(path: path!)
                                    } else {
                                        Alertinator.shared.alert(title: "Invalid Path", body: "Enter a vaild path.")
                                    }
                                }
                            } label: {
                                Label("Custom Path", systemImage: "apple.terminal")
                            }
                            .disabled(!isSupported)
                            
                            Button {
                                dirtyZeroHide(path: "/usr/lib/dyld")
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
                                    Color(.systemBackground).opacity(0.8)
                                ]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                    }
                }
                .navigationTitle("dirtyZero")
                // this will make people who cannot read cry
                .onAppear {
                    let version = Double(device.systemVersion!)!
                    if version >= 18.4 {
                        isSupported = false
                    }
                }
            }
        }
    }
    
    func dirtyZeroHide(path: String) {
        do {
            try zeroPoC(path: path)
            print("[*] All tweaks applied successfully!")
            Alertinator.shared.alert(title: "Tweaks Applied", body: "Now, respring using your preferred method. If you have RespringApp installed, click the now smaller, orange Respring button.")
        } catch {
            Alertinator.shared.alert(title: "Exploit Failed", body: "There was an error while running the exploit: \(error).")
            print("[!] Exploit Failed: There was an error while running the exploit: \(error).")
        }
    }
    
    // The "sandbox escape" :fire: (it literally just shows you installed apps and does nothing else of actual use)
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

// just trust me skadz
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
                    if Double(device.systemVersion!)! <= tweak.maxSupportedVersion && Double(device.systemVersion!)! >= tweak.minSupportedVersion {
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
                        .buttonStyle(ListButtonStyle(color: isTweakEnabled(tweak) ? .accent : .accent.opacity(0.8), fullWidth: false))
                    }
                }
            }
            .listRowInsets(EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16))
        }
    }
}

// Buttons :fire:
struct RegularButtonStyle: View {
    let text: String
    let icon: String
    let useMaxHeight: Bool
    let disabled: Bool
    let foregroundStyle: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
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

// List Styling
struct ListButtonStyle: ButtonStyle {
    var color: Color
    var material: UIBlurEffect.Style?
    var fullWidth: Bool = false
    
    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            if fullWidth {
                configuration.label
                    .padding(12)
                    .frame(maxWidth: .infinity)
                    .background(material == nil ? AnyView(color.opacity(0.2)) : AnyView(MaterialView(material!)))
                    .cornerRadius(10)
                    .foregroundStyle(color)
            } else {
                configuration.label
                    .padding(12)
                    .frame(maxWidth: .infinity)
                    .background(material == nil ? AnyView(color.opacity(0.2)) : AnyView(MaterialView(material!)))
                    .cornerRadius(10)
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
