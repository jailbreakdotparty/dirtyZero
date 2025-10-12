//
//  ViewExtensions.swift
//  dirtyZero
//
//  Created by jailbreak.party on 10/8/25.
//

import SwiftUI
import UIKit
import DeviceKit

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
    
    private var isRiskyTweak: Bool {
        sectionLabel == "Risky Tweaks"
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
        Section(header: HeaderStyle(label: sectionLabel, icon: sectionIcon)) {
            if isRiskyTweak {
                HStack(spacing: 10) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.title)
                        .frame(width: 35, height: 35)
                    VStack(alignment: .leading) {
                        Text("Warning!")
                            .fontWeight(.semibold)
                        Text("These tweaks could break system functionality. You may have to force reboot your device.")
                            .multilineTextAlignment(.leading)
                            .font(.subheadline)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .foregroundStyle(.white)
                .padding(10)
                .background(.red)
                .cornerRadius(14)
            }
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
                                    .foregroundStyle(isRiskyTweak ? .red : .accent)
                                Text(tweak.name)
                                    .lineLimit(1)
                                    .scaledToFit()
                                    .foregroundStyle(isRiskyTweak ? .red : .accent)
                                Spacer()
                                if isTweakEnabled(tweak) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(isRiskyTweak ? .red : .accent)
                                        .imageScale(.medium)
                                } else {
                                    Image(systemName: "circle")
                                        .foregroundStyle(isRiskyTweak ? .red : .accent)
                                        .imageScale(.medium)
                                }
                            }
                        }
                        .buttonStyle(ListButtonStyle(color: isTweakEnabled(tweak) ? isRiskyTweak ? .red : .accent : isRiskyTweak ? .red.opacity(0.7) : .accent.opacity(0.7), fullWidth: false))
                    }
                }
            }
        }
    }
}

// the same idea but for the Custom Tweaks category only
struct CustomTweakSectionList: View {
    let sectionLabel = "Custom Tweaks"
    let sectionIcon = "paintpalette"
    let tweaks: [ZeroTweak]
    @Binding var enabledTweakIds: [String]
    
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
    
    @AppStorage("customTweaks") private var customTweaks: [ZeroTweak] = []
    
    var body: some View {
        Section(header: HeaderStyle(label: sectionLabel, icon: sectionIcon)) {
            VStack {
                ForEach(tweaks) { tweak in
                    Button(action: {
                        Haptic.shared.play(.soft)
                        toggleTweak(tweak)
                    }) {
                        HStack {
                            Image(systemName: tweak.icon)
                                .frame(width: 24, alignment: .center)
                                .foregroundStyle(.purple)
                            Text(tweak.name)
                                .lineLimit(1)
                                .scaledToFit()
                                .foregroundStyle(.purple)
                            Spacer()
                            if isTweakEnabled(tweak) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.purple)
                                    .imageScale(.medium)
                            } else {
                                Image(systemName: "circle")
                                    .foregroundStyle(.purple)
                                    .imageScale(.medium)
                            }
                        }
                    }
                    .buttonStyle(ListButtonStyle(color: isTweakEnabled(tweak) ? .purple : .purple.opacity(0.7), fullWidth: false))
                    .contextMenu {
                        Button(action: {
                            Alertinator.shared.alert(title: tweak.name, body: tweak.paths.joined(separator: ", "))
                        }) {
                            Label("Target Paths", systemImage: "folder")
                        }
                        Button(role: .destructive, action: {
                            customTweaks.removeAll { $0.id == tweak.id }
                        }) {
                            Label("Delete Tweak", systemImage: "xmark")
                        }
                    }
                }
            }
        }
    }
}

// buttons :fire:
struct RegularButtonStyle: View {
    let text: String
    let icon: String
    let isPNGIcon: Bool
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
                if isPNGIcon {
                    Image(icon)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 22, maxHeight: 22)
                } else {
                    Image(systemName: icon)
                        .frame(width: 22, height: 22, alignment: .center)
                }
                if text.isEmpty {
                    
                } else {
                    Text(text)
                }
            }
        }
        .padding(13)
        .frame(maxWidth: .infinity)
        .background(disabled ? .gray.opacity(0.4) : foregroundStyle.opacity(0.2))
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
                    .padding(12)
                    .frame(maxWidth: .infinity)
                    .background(material == nil ? AnyView(color.opacity(0.2)) : AnyView(MaterialView(material!)))
                    .cornerRadius(14)
                    .foregroundStyle(color)
            } else {
                configuration.label
                    .padding(12)
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

struct HeaderStyle: View {
    let label: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .frame(width: 24, alignment: .center)
            Text(label)
        }
        .font(.system(.callout, weight: .semibold))
        .padding(.top)
        .opacity(0.6)
        .padding(.leading, 6)
    }
}
