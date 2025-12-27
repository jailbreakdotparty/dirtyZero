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

// so uhh you're probably wondering why i did what i did skadz with the whole isExpanded and isExpandedStorage thing. so, animations would break if i converted isExpanded into an AppStorage property directly, but keeping isExpanded as a state and connecting it with isExpandedStorage (as AppStorage) would allow HeaderDropdown to actually send the animation. it sucks but it works so whatever, womp womp. -lunginspector, 12/26/25

struct TweakSectionList: View {
    var sectionLabel: String
    var sectionIcon: String
    var tweaks: [ZeroTweak]
    var isRiskyTweak: Bool = false
    var isCustomTweak: Bool = false
    
    @State private var isExpanded: Bool = false
    @State private var tweakCount: Int = 0
    
    @Binding var enabledTweakIds: [String]
    
    @AppStorage("customTweaks") private var customTweaks: [ZeroTweak] = []
    @AppStorage private var isExpandedStorage: Bool
    
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
    
    // this allows us to generate isExpandedStorage properties for each section. had some trouble comphrending it at first but you gotta add those initalizations if the property is getting data from somewhere else. 
    init(sectionLabel: String, sectionIcon: String, tweaks: [ZeroTweak], isRiskyTweak: Bool = false, isCustomTweak: Bool = false, enabledTweakIds: Binding<[String]>) {
        self.sectionLabel = sectionLabel
        self.sectionIcon = sectionIcon
        self.tweaks = tweaks
        self.isRiskyTweak = isRiskyTweak
        self.isCustomTweak = isCustomTweak
        self._enabledTweakIds = enabledTweakIds
        self._isExpandedStorage = AppStorage(wrappedValue: true, "sectionExpanded_\(sectionLabel)")
    }
    
    var body: some View {
        Section(header: HeaderDropdown(text: sectionLabel, icon: sectionIcon, isExpanded: $isExpanded, useCount: true, itemCount: tweakCount)) {
            if isExpanded {
                if isRiskyTweak {
                    HStack(spacing: 12) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.title)
                            .frame(width: 35, height: 35)
                        VStack(alignment: .leading) {
                            Text("Warning!")
                                .fontWeight(.semibold)
                            Text("These tweaks could break system functionality.")
                                .multilineTextAlignment(.leading)
                                .font(.subheadline)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .foregroundStyle(.red)
                    .padding()
                    .modifier(DynamicGlassEffect(color: .red.opacity(0.4)))
                    .cornerRadius(14)
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
                                Image(systemName: isTweakEnabled(tweak) ? "checkmark.circle.fill" : "circle")
                                    .animation(.easeInOut(duration: 0.15), value: isTweakEnabled(tweak))
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
                                    }) {
                                        Label("Delete Tweak", systemImage: "xmark")
                                    }
                                }
                            }
                        }
                        .buttonStyle(.plain)
                        .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                    }
                }
            }
        }
        .listRowSeparator(.hidden)
        .onAppear {
            // this syncs up the regular expanded and the storage one ONLY WHEN IT APPEARS
            isExpanded = isExpandedStorage
            tweakCount = tweaks.filter { tweak in
                doubleSystemVersion() <= tweak.maxSupportedVersion &&
                doubleSystemVersion() >= tweak.minSupportedVersion ||
                weOnADebugBuild
            }.count
        }
        .onChange(of: isExpanded) { newValue in
            // this syncs it up whenever the state changes
            isExpandedStorage = newValue
        }
        .onChange(of: tweaks) { newValue in
            if newValue.isEmpty {
                isExpanded = false
            } else if !newValue.isEmpty && tweaks.isEmpty {
                isExpanded = true
            }
            tweakCount = newValue.filter { tweak in
                doubleSystemVersion() <= tweak.maxSupportedVersion &&
                doubleSystemVersion() >= tweak.minSupportedVersion ||
                weOnADebugBuild
            }.count
        }
    }
}
