//
//  ViewExtensions.swift
//  dirtyZero
//
//  Created by jailbreak.party on 10/8/25.
//

import SwiftUI
import UIKit
import DeviceKit
import PartyUI

// primary spacing between list items: itemRowInsets, spaces between each dropdown/header and adds padding for left right (think of this as the container)
// internal spacing: contentInsets

struct TweakSectionList: View {
    var sectionLabel: String
    var sectionIcon: String
    var tweaks: [ZeroTweak]
    var isRiskyTweak: Bool = false
    var isCustomTweak: Bool = false
    
    @State private var isExpanded: Bool = true
    @State private var tweakCount: Int = 0
    
    @Binding var enabledTweakIds: [String]
    
    @AppStorage("customTweaks") private var customTweaks: [ZeroTweak] = []
    
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
    
    let device = Device.current
    
    var body: some View {
        Section(header: HeaderDropdown(text: sectionLabel, icon: sectionIcon, useCount: true, itemCount: tweakCount, isExpanded: $isExpanded)) {
            if isExpanded {
                Group {
                    if isRiskyTweak {
                        ContextualWarning(icon: "exclamationmark.triangle", label: "Warning!", text: "These tweaks will temporarily break system functionality.", color: .red)
                    }
                    let color: Color = isRiskyTweak ? .red : isCustomTweak ? .purple : .accentColor
                    
                    ForEach(tweaks) { tweak in
                        if doubleSystemVersion() <= tweak.maxSupportedVersion && doubleSystemVersion() >= tweak.minSupportedVersion || weOnADebugBuild {
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
                                    AnimatedToggle(isOn: isTweakEnabled(tweak))
                                }
                                .foregroundStyle(color)
                                .modifier(GlassyListRowBackground(color: color))
                                .contextMenu {
                                    Button(action: {
                                        Alertinator.shared.alert(title: tweak.name, body: tweak.paths.joined(separator: ", "))
                                    }) {
                                        Label("Target Paths", systemImage: "folder")
                                    }
                                    if isCustomTweak {
                                        Button(role: .destructive, action: {
                                            customTweaks.removeAll { $0.id == tweak.id }
                                            enabledTweakIds.removeAll { $0 == tweak.id }
                                        }) {
                                            Label("Delete Tweak", systemImage: "xmark")
                                        }
                                    }
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
        }
        .listRowSeparator(.hidden)
        .listRowInsets(.dropdownRowInsets)
        .onAppear {
            tweakCount = tweaks.filter { tweak in
                doubleSystemVersion() <= tweak.maxSupportedVersion &&
                doubleSystemVersion() >= tweak.minSupportedVersion ||
                weOnADebugBuild
            }.count
        }
        .onChange(of: tweaks) { newValue in
            tweakCount = newValue.filter { tweak in
                doubleSystemVersion() <= tweak.maxSupportedVersion &&
                doubleSystemVersion() >= tweak.minSupportedVersion ||
                weOnADebugBuild
            }.count
        }
    }
}
