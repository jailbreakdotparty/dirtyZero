//
//  ContentView.swift
//  dirtyZero
//
//  Created by Skadz on 5/8/25.
//

import SwiftUI
import DeviceKit
import notify

struct ZeroTweak: Identifiable, Codable {
    var id: String { name }
    var icon: String
    var name: String
    var paths: [String]
    
    enum CodingKeys: String, CodingKey {
        case icon, name, paths
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

var tweaks: [ZeroTweak] = [
    ZeroTweak(icon: "dock.rectangle", name: "Hide Dock", paths: ["/System/Library/PrivateFrameworks/CoreMaterial.framework/dockDark.materialrecipe", "/System/Library/PrivateFrameworks/CoreMaterial.framework/dockLight.materialrecipe"]),
    ZeroTweak(icon: "line.3.horizontal", name: "Hide Home Bar", paths: ["/System/Library/PrivateFrameworks/MaterialKit.framework/Assets.car"]),
    ZeroTweak(icon: "folder", name: "Hide Folder Backgrounds", paths: ["/System/Library/PrivateFrameworks/SpringBoardHome.framework/folderDark.materialrecipe", "/System/Library/PrivateFrameworks/SpringBoardHome.framework/folderLight.materialrecipe"]),
    ZeroTweak(icon: "bell.badge", name: "Hide Notification Backgrounds", paths: ["/System/Library/PrivateFrameworks/CoreMaterial.framework/platterStrokeLight.visualstyleset", "/System/Library/PrivateFrameworks/CoreMaterial.framework/platterStrokeDark.visualstyleset", "/System/Library/PrivateFrameworks/CoreMaterial.framework/plattersDark.materialrecipe", "/System/Library/PrivateFrameworks/CoreMaterial.framework/platters.materialrecipe"]),
    ZeroTweak(icon: "lock.iphone", name: "Hide Unlock Background", paths: ["/System/Library/PrivateFrameworks/CoverSheet.framework/dashBoardPasscodeBackground.materialrecipe"])
    ZeroTweak(icon: "gearshape", name: "Partial Internal Localization Keys For Settings App", paths:
                ["/System/Library/PrivateFrameworks/Settings/SoundsAndHapticsSettings.framework/Sounds.loctable",
                 "/System/Library/PrivateFrameworks/Settings/DisplayAndBrightnessSettings.framework/ColorSchedule.loctable",
                 "/System/Library/PrivateFrameworks/Settings/DisplayAndBrightnessSettings.framework/ColorTemperature.loctable",
                 "/System/Library/PrivateFrameworks/Settings/DisplayAndBrightnessSettings.framework/DeviceAppearanceSchedule.loctable",
                 "/System/Library/PrivateFrameworks/Settings/DisplayAndBrightnessSettings.framework/Display.loctable",
                 "/System/Library/PrivateFrameworks/Settings/DisplayAndBrightnessSettings.framework/ExternalDisplays.loctable",
                 "/System/Library/PrivateFrameworks/Settings/DisplayAndBrightnessSettings.framework/FineTune.loctable",
                 "/System/Library/PrivateFrameworks/Settings/DisplayAndBrightnessSettings.framework/LargeFontsSettings.loctable",
                 "/System/Library/PrivateFrameworks/Settings/DisplayAndBrightnessSettings.framework/Magnify.loctable",
                 "/System/Library/PrivateFrameworks/Settings/GeneralSettingsUI.framework/About.loctable",
                 "/System/Library/PrivateFrameworks/Settings/GeneralSettingsUI.framework/AutomaticContentDownload.loctable",
                 "/System/Library/PrivateFrameworks/Settings/GeneralSettingsUI.framework/BackupAlert.loctable",
                 "/System/Library/PrivateFrameworks/Settings/GeneralSettingsUI.framework/BackupInfo.loctable",
                 "/System/Library/PrivateFrameworks/Settings/GeneralSettingsUI.framework/Date & Time.loctable",
                 "/System/Library/PrivateFrameworks/Settings/GeneralSettingsUI.framework/General.loctable",
                 "/System/Library/PrivateFrameworks/Settings/GeneralSettingsUI.framework/HomeButton-sshb.loctable",
                 "/System/Library/PrivateFrameworks/Settings/GeneralSettingsUI.framework/Localizable.loctable",
                 "/System/Library/PrivateFrameworks/Settings/GeneralSettingsUI.framework/LOTX.loctable",
                 "/System/Library/PrivateFrameworks/Settings/GeneralSettingsUI.framework/Matter.loctable",
                 "/System/Library/PrivateFrameworks/Settings/GeneralSettingsUI.framework/ModelNames.loctable",
                 "/System/Library/PrivateFrameworks/Settings/GeneralSettingsUI.framework/Nfc.loctable",
                 "/System/Library/PrivateFrameworks/Settings/GeneralSettingsUI.framework/Nfc.loctable",
                 "/System/Library/PrivateFrameworks/Settings/GeneralSettingsUI.framework/Pointers.loctable",
                 "/System/Library/PrivateFrameworks/Settings/GeneralSettingsUI.framework/Reset-Simulator.loctable",
                 "/System/Library/PrivateFrameworks/Settings/GeneralSettingsUI.framework/Reset.loctable",
                 "/System/Library/PrivateFrameworks/Settings/PrivacySettingsUI.framework/Privacy.loctable",
                 "/System/Library/PrivateFrameworks/Settings/PrivacySettingsUI.framework/Almanac-ALMANAC.loctable",
                 "/System/Library/PrivateFrameworks/Settings/PrivacySettingsUI.framework/AppleAdvertising.loctable",
                 "/System/Library/PrivateFrameworks/Settings/PrivacySettingsUI.framework/AppReport.loctable",
                 "/System/Library/PrivateFrameworks/Settings/PrivacySettingsUI.framework/Dim-Sum.loctable",
                 "/System/Library/PrivateFrameworks/Settings/PrivacySettingsUI.framework/Localizable.loctable",
                 "/System/Library/PrivateFrameworks/Settings/PrivacySettingsUI.framework/Location Services.loctable",
                 "/System/Library/PrivateFrameworks/Settings/PrivacySettingsUI.framework/LocationServicesPrivacy.loctable",
                 "/System/Library/PrivateFrameworks/Settings/PrivacySettingsUI.framework/LockdownMode.loctable",
                 "/System/Library/PrivateFrameworks/Settings/PrivacySettingsUI.framework/Privacy.loctable",
                 "/System/Library/PrivateFrameworks/Settings/PrivacySettingsUI.framework/Restrictions.loctable",
                 "/System/Library/PrivateFrameworks/Settings/PrivacySettingsUI.framework/Safety.loctable",
                 "/System/Library/PrivateFrameworks/Settings/PrivacySettingsUI.framework/Trackers.loctable",
                ]),
    ZeroTweak(icon: "doc.text", name: "Black Screen/Respring Loop Device", paths: ["/System/Library/CoreServices/SystemVersion.plist"]),
    ZeroTweak(icon: "arrow.2.circlepath", name: "Reboot Device", paths: ["/System/Library/CoreServices/powerd.bundle/powerd"]),
]

struct ContentView: View {
    let device = Device.current
    @AppStorage("enabledTweaks") private var enabledTweakIds: [String] = []
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
            VStack {
                List {
                    Section(header: HStack {
                        Image(systemName: "terminal.fill")
                        Text("Logs")
                    }) {
                        HStack {
                            Spacer()
                            ZStack {
                                LogView()
                                    .padding(3)
                                    .frame(width: 340, height: 260)
                            }
                            Spacer()
                        }
                        .onAppear(perform: {
                            print("[*] Welcome to dirtyZero!\n[*] Running on \(device.systemName!) \(device.systemVersion!), \(device.description)")
                        })
                    }
                    
                    Section(header: HStack {
                        Image(systemName: "hammer.fill")
                        Text("Tweaks")
                    }) {
                        VStack {
                            ForEach(tweaks) { tweak in
                                Button(action: {
                                    Haptic.shared.play(.soft)
                                    toggleTweak(tweak)
                                }) {
                                    HStack {
                                        Image(systemName: tweak.icon)
                                            .frame(width: 24, alignment: .center)
                                        Text(tweak.name)
                                            .lineLimit(1)
                                            .scaledToFit()
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
                                .buttonStyle(TintedButton(color: .accent, fullWidth: false))
                            }
                        }
                    }
                    
                    Section(header: HStack {
                        Image(systemName: "gear")
                        Text("Actions")
                    }, footer: Text("All tweaks are done in memory, so if something goes wrong, you can force reboot to revert changes.\n\nExploit discovered by Ian Beer of Google Project Zero. Created by the jailbreak.party team.")) {
                        Button(action: {
                            var applyingString = "[*] Applying the selected tweaks: "
                            let tweakNames = enabledTweaks.map { $0.name }.joined(separator: ", ")
                            applyingString += tweakNames
                            
                            print(applyingString)
                            
                            for tweak in enabledTweaks {
                                for path in tweak.paths {
                                    dirtyZeroHide(path: path)
                                }
                            }
                            
                            print("[*] All tweaks applied successfully!")
                        }) {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                Text("Apply")
                            }
                        }
                        .buttonStyle(TintedButton(color: enabledTweaks.isEmpty ? .accent.dark() : .accent, fullWidth: true))
                        .contextMenu {
                            Button {
                                Alertinator.shared.prompt(title: "Enter custom path", placeholder: "/path/to/the/file/to/hide") { path in
                                    if let _ = path, !path!.isEmpty {
                                        dirtyZeroHide(path: path!)
                                    } else {
                                        Alertinator.shared.alert(title: "Invalid path", body: "Enter an actual path to what you want to hide/zero.")
                                    }
                                }
                            } label: {
                                Label("(Debug) Use custom file path", systemImage: "apple.terminal")
                            }
                        }
                        .disabled(enabledTweaks.isEmpty)
                    }
                }
            }
            .navigationTitle("dirtyZero")
        }
    }
    
    func dirtyZeroHide(path: String) {
        let args = ["permasign", path]
        var argv = args.map { strdup($0) }
        
        _ = permasign(Int32(args.count), &argv)
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

struct TintedButton: ButtonStyle {
    var color: Color
    var material: UIBlurEffect.Style?
    var fullWidth: Bool = false
    
    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            if fullWidth {
                configuration.label
                    .padding(15)
                    .frame(maxWidth: .infinity)
                    .background(material == nil ? AnyView(color.opacity(0.2)) : AnyView(MaterialView(material!)))
                    .cornerRadius(8)
                    .foregroundStyle(color)
            } else {
                configuration.label
                    .padding(15)
                    .frame(maxWidth: .infinity)
                    .background(material == nil ? AnyView(color.opacity(0.2)) : AnyView(MaterialView(material!)))
                    .cornerRadius(8)
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
