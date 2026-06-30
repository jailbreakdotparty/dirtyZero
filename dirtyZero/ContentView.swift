//
//  ContentView.swift
//  dirtyZero
//
//  Created by Skadz on 5/8/25.
//

import SwiftUI
import PartyUI
import UIKit

struct ContentView: View {
    @EnvironmentObject var mgr: dirtyZeroManager
    
    @AppStorage("tweakArray") var tweakArray: [ZeroSection] = TweakArray.tweaks
    
    @AppStorage("enableDebugSettings") var enableDebugSettings: Bool = false
    @AppStorage("enableRiskyTweaks") var enableRiskyTweaks: Bool = false
    
    @State private var customZeroPath: String = ""
    
    @State private var showSettingsView: Bool = false
    @State private var showCustomTweaksView: Bool = false
    
    @State private var selectedTweak: ZeroTweak?
    @State private var tweakType: SectionType = .normal
    
    let version = doubleSystemVersion()
    
    var body: some View {
        Group {
            if UIDevice.current.userInterfaceIdiom == .phone {
                NavigationStack {
                    List {
                        ApplyingSection
                            .listRowSeparator(.hidden)
                        if enableDebugSettings {
                            DebuggingSection
                                .listRowSeparator(.hidden)
                        }
                        ListedTweaksSection
                            .listRowSeparator(.hidden)
                    }
                    .listStyle(.plain)
                    .navigationTitle("dirtyZero")
                    .safeAreaInset(edge: .bottom) {
                        ApplyingButtons
                            .modifier(OverlayBackground())
                    }
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) {
                            Button {
                                showSettingsView.toggle()
                            } label: {
                                Image(systemName: "gear")
                            }
                        }
                        
                        ToolbarItem(placement: .topBarTrailing) {
                            Button {
                                showCustomTweaksView.toggle()
                            } label: {
                                Image(systemName: "paintbrush")
                            }
                        }
                    }
                }
            } else {
                NavigationSplitView {
                    List {
                        ApplyingSection
                            .listRowSeparator(.hidden)
                        ApplyingButtons
                        if enableDebugSettings {
                            DebuggingSection
                                .listRowSeparator(.hidden)
                        }
                    }
                    .listStyle(.plain)
                    .navigationTitle("dirtyZero")
                    .navigationSplitViewColumnWidth(385)
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) {
                            Button {
                                showSettingsView.toggle()
                            } label: {
                                Image(systemName: "gear")
                            }
                        }
                        
                        ToolbarItem(placement: .topBarTrailing) {
                            Button {
                                showCustomTweaksView.toggle()
                            } label: {
                                Image(systemName: "paintbrush")
                            }
                        }
                    }
                } detail: {
                    List {
                        ListedTweaksSection
                    }
                    .listStyle(.plain)
                    .navigationTitle("Tweaks")
                    .navigationBarTitleDisplayMode(.inline)
                }
            }
        }
        .onChange(of: tweakArray) { _ in
            let tweaks = tweakArray.flatMap { $0.tweaks }
            mgr.enabledTweaks = tweaks.filter { $0.isOn }.count
        }
        .onAppear {
            let tweaks = tweakArray.flatMap { $0.tweaks }
            mgr.enabledTweaks = tweaks.filter { $0.isOn }.count
        }
        .sheet(isPresented: $showSettingsView) {
            SettingsView()
        }
        .sheet(isPresented: $showCustomTweaksView) {
            CustomTweaksView()
        }
        .sheet(item: $selectedTweak) { tweak in
            TweakInfoView(tweak: tweak, tweakType: tweakType)
        }
    }
    
    private var ApplyingSection: some View {
        Section {
            VStack(alignment: .leading) {
                HStack {
                    TerminalHeader(text: mgr.applyShortStatus, icon: mgr.applyIcon, color: mgr.applyColor)
                    Text("\(mgr.applyCurrentTweak)/\(mgr.enabledTweaks)")
                }
                if !mgr.applyStatus.isEmpty {
                    Text(mgr.applyStatus)
                        .foregroundStyle(.secondary)
                        .font(.subheadline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                LogView()
                    .modifier(TerminalPlatter())
            }
            .modifier(SectionPlatter())
        } header: {
            HeaderLabel(text: "Logs", icon: "terminal")
        } footer: {
            Text("Made with love by the [jailbreak.party](https://jailbreak.party) team.\nJoin the jailbreak.party [discord!](https://jailbreak.party/discord)")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .listRowInsets(.sectionInsets)
    }
    
    private var DebuggingSection: some View {
        Section {
            HStack {
                TextField("Custom Path", text: $customZeroPath)
                    .modifier(TextFieldBackground())
                Button {
                    do {
                        try zeroAtPath(path: customZeroPath)
                        Haptic.shared.play(.soft)
                    } catch {
                        print("[!] failed to zero custom path at \(customZeroPath): \(error)")
                    }
                } label: {
                    Image(systemName: "checkmark")
                        .frame(width: 24, height: 24)
                }
                .buttonStyle(TranslucentButtonStyle(color: .green, useFullWidth: false))
                .disabled(customZeroPath.isEmpty)
            }
            
            Button {
                tweakArray = TweakArray.tweaks
                Haptic.shared.play(.heavy)
            } label: {
                HeaderLabel(text: "Reset tweakArray", icon: "trash")
            }
            .buttonStyle(TranslucentButtonStyle(color: .red))
        } header: {
            HeaderLabel(text: "Debug", icon: "ant")
        }
        .listRowInsets(.sectionInsets)
    }
    
    private var ListedTweaksSection: some View {
        Group {
            ForEach($tweakArray) { $section in
                if section.sectionType != .risky || (section.sectionType == .risky && enableRiskyTweaks || enableDebugSettings) {
                    Section {
                        if section.isExpanded {
                            ForEach($section.tweaks) { $tweak in
                                PlatterToggle(
                                    text: tweak.name,
                                    icon: tweak.icon,
                                    color: Color(hex: section.hex),
                                    ignoreVrs: enableDebugSettings,
                                    minSupportedVersion: tweak.minSupportedVersion,
                                    maxSupportedVersion: tweak.maxSupportedVersion,
                                    isOn: $tweak.isOn
                                )
                                .swipeActions {
                                    Button(action: {
                                        tweakType = section.sectionType
                                        selectedTweak = tweak
                                    }) {
                                        Image(systemName: "info.circle")
                                    }
                                    .tint(Color(.secondarySystemBackground))
                                    
                                    if section.sectionType == .custom {
                                        Button {
                                            if let index = tweakArray.firstIndex(where: { $0.name == "Custom Tweaks" }) {
                                                tweakArray[index].tweaks.removeAll { $0.id == tweak.id }
                                            }
                                            Haptic.shared.play(.heavy)
                                        } label: {
                                            Image(systemName: "trash")
                                        }
                                        .tint(.red)
                                    }
                                }
                            }
                        }
                    } header: {
                        HeaderDropdown(
                            text: section.name,
                            icon: section.icon,
                            isExpanded: $section.isExpanded,
                            useItemCount: true,
                            itemCount: section.tweaks.filter { enableDebugSettings || (doubleSystemVersion() >= $0.minSupportedVersion && doubleSystemVersion() <= $0.maxSupportedVersion) }.count
                        )
                    }
                    .listRowInsets(.sectionInsets)
                }
            }
        }
    }
    
    private var ApplyingButtons: some View {
        VStack {
            Button {
                Haptic.shared.play(.soft)
                mgr.applyTweaks(tweakData: tweakArray)
            } label: {
                ButtonLabel(text: "Apply Tweaks", icon: "checkmark")
            }
            .buttonStyle(FancyButtonStyle(color: .green))
            
            HStack {
                Button {
                    Haptic.shared.play(.heavy)
                    mgr.revertTweaks()
                } label: {
                    ButtonLabel(text: "Revert", icon: "xmark")
                }
                .buttonStyle(FancyButtonStyle(color: .red))
                
                Button {
                    Haptic.shared.play(.soft)
                    mgr.respringDevice()
                } label: {
                    ButtonLabel(text: "Respring", icon: "goforward")
                }
                .buttonStyle(FancyButtonStyle(color: .orange))
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(dirtyZeroManager())
}
