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

enum SectionType {
    case custom, risky, normal
}

struct ContentView: View {
    @EnvironmentObject var mgr: dirtyZeroManager
    @AppStorage("tweakArray") var tweakArray: [ZeroSection] = TweakArray.tweaks
    @AppStorage("enableDebugSettings") var enableDebugSettings: Bool = false
    @AppStorage("enableRiskyTweaks") var enableRiskyTweaks: Bool = false
    
    @State private var showSettingsView: Bool = false
    @State private var showCustomTweaksView: Bool = false
    @State private var customZeroPath: String = ""
    @State private var selectedTweak: ZeroTweak?
    
    @State private var hasOffsets: Bool = false
    @State private var fetchingKcache = false
    
    let version = doubleSystemVersion()
    
    var body: some View {
        Group {
            if UIDevice.current.userInterfaceIdiom == .phone {
                NavigationStack {
                    List {
                        AlertsSection
                            .listRowSeparator(.hidden)
                        ApplyingSection
                            .listRowSeparator(.hidden)
                        if enableDebugSettings {
                            DebuggingSection
                                .listRowSeparator(.hidden)
                        }
                        ListedTweaksSection
                            .disabled(mgr.chosenExploit == .DarkSword && !mgr.vfsready)
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
                            Button(action: { showSettingsView.toggle() }) {
                                Image(systemName: "gear")
                            }
                        }
                        ToolbarItem(placement: .topBarTrailing) {
                            Button(action: { showCustomTweaksView.toggle() }) {
                                Image(systemName: "paintbrush")
                            }
                        }
                    }
                }
            } else {
                NavigationSplitView(sidebar: {
                    List {
                        ApplyingSection
                            .listRowSeparator(.hidden)
                            .listRowInsets(.sectionInsets)
                        ApplyingButtons
                        if enableDebugSettings {
                            DebuggingSection
                                .listRowSeparator(.hidden)
                        }
                    }
                    .listStyle(.plain)
                    .navigationTitle("dirtyZero")
                    .modifier(RemoveSidebarToggle())
                    .navigationSplitViewColumnWidth(385)
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) {
                            Button(action: { showSettingsView.toggle() }) {
                                Image(systemName: "gear")
                            }
                        }
                        ToolbarItem(placement: .topBarTrailing) {
                            Button(action: { showCustomTweaksView.toggle() }) {
                                Image(systemName: "paintbrush")
                            }
                        }
                    }
                }) {
                    List {
                        ListedTweaksSection
                    }
                    .listStyle(.plain)
                    .toolbar(.hidden, for: .navigationBar)
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
            TweakInfoView(tweak: tweak)
        }
    }
    
    private var AlertsSection: some View {
        Group {
            if !mgr.hasOffsets && mgr.chosenExploit == .DarkSword {
                Button(action: {
                    showSettingsView.toggle()
                }) {
                    CompactAlert(title: "Offsets are missing!", icon: "exclamationmark.triangle.fill", text: "Offsets are required to use DarkSword. Click \"Run Exploit\", then click \"Fetch Kernelcache\".")
                }
            }
        }
        .listRowInsets(.sectionInsets)
    }
    
    // MARK: Applying Section
    private var ApplyingSection: some View {
        Section(header: HeaderLabel(text: "Logs", icon: "terminal"), footer: Text("Made with love by the [jailbreak.party](https://jailbreak.party) team.\nJoin the jailbreak.party [discord!](https://jailbreak.party/discord)").font(.footnote).foregroundStyle(.secondary)) {
            VStack {
                VStack(alignment: .leading) {
                    HStack {
                        HStack {
                            Image(systemName: mgr.applyIcon)
                            Text(mgr.applyShortStatus)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .fontWeight(.semibold)
                        }
                        Text("\(mgr.applyCurrentTweak)/\(mgr.enabledTweaks)")
                    }
                }
                .tint(mgr.applyColor)
                LogView()
                    .modifier(TerminalPlatter())
            }
            .modifier(SectionPlatter())
        }
        .listRowInsets(.sectionInsets)
    }
    
    // MARK: Debugging Section
    private var DebuggingSection: some View {
        Section(header: HeaderLabel(text: "Debugging", icon: "ant")) {
            HStack {
                TextField("Custom Path", text: $customZeroPath)
                    .modifier(TextFieldBackground())
                Button(action: {
                    do {
                        try mgr.zeroPage(path: customZeroPath)
                    } catch {
                        Alertinator.shared.alert(title: "Failed to zero file!", body: "\(error)")
                    }
                }) {
                    Image(systemName: "checkmark")
                        .frame(width: 24, height: 24)
                }
                .buttonStyle(TranslucentButtonStyle(color: .green, useFullWidth: false))
                .disabled(customZeroPath.isEmpty)
            }
            Button(action: {
                tweakArray = TweakArray.tweaks
            }) {
                HeaderLabel(text: "Reset TweakArray", icon: "trash")
            }
            .buttonStyle(TranslucentButtonStyle(color: .red))
        }
        .listRowInsets(.sectionInsets)
    }
    
    // MARK: Listed Tweaks Section
    // i hate this whole section a lot, but breaking this up into three seperate arrays would suck for management. this is likely the best solution.
    private var ListedTweaksSection: some View {
        ForEach($tweakArray) { $section in
            let sectionType: SectionType = section.name == "Custom Tweaks" ? .custom : section.name == "Risky Tweaks" ? .risky : .normal
            
            if sectionType == .risky && enableRiskyTweaks || sectionType != .risky && !section.tweaks.isEmpty {
                Section(header: HeaderDropdown(text: section.name, icon: section.icon, isExpanded: $section.isExpanded, useItemCount: true, itemCount: section.tweaks.filter { version >= $0.minSupportedVersion && version <= $0.maxSupportedVersion || enableDebugSettings }.count)) {
                    if section.isExpanded {
                        let sectionColor = sectionType == .custom ? .purple : sectionType == .risky ? .red : Color.accentColor
                        
                        ForEach($section.tweaks) { $tweak in
                            if (version >= tweak.minSupportedVersion && version <= tweak.maxSupportedVersion) || enableDebugSettings {
                                Button(action: {
                                    tweak.isOn.toggle()
                                }) {
                                    HStack(spacing: 10) {
                                        Image(systemName: tweak.icon)
                                            .frame(width: 22, height: 20)
                                        Text(tweak.name)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                        Image(systemName: tweak.isOn ? "checkmark.circle.fill" : "circle")
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                .buttonStyle(TranslucentButtonStyle(color: sectionColor))
                                .listRowSeparator(.hidden)
                                .listRowInsets(.sectionInsets)
                                .swipeActions {
                                    Button(action: {
                                        selectedTweak = tweak
                                    }) {
                                        Image(systemName: "info.circle")
                                    }
                                    if sectionType == .custom {
                                        Button(action: {
                                            let customTweaksIndex = tweakArray.firstIndex(where: { $0.name == "Custom Tweaks" }) ?? 0
                                            
                                            tweakArray[customTweaksIndex].tweaks.removeAll { $0.name == tweak.name }
                                        }) {
                                            Image(systemName: "trash")
                                        }
                                        .tint(.red)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    // MARK: Applying Buttons
    private var ApplyingButtons: some View {
        VStack {
            if mgr.chosenExploit == .DarkSword && !mgr.vfsready {
                if !mgr.hasOffsets {
                    // run offsets
                    Button(action: {
                        offsets_init()
                        mgr.run()
                    }) {
                        if mgr.dsfailed || mgr.vfsfailed {
                            ButtonLabel(text: "Exploit Failed!", icon: "xmark")
                        } else if mgr.dsrunning || mgr.vfsrunning {
                            ButtonLabel(text: "Running Exploit...", icon: "showMeProgressPlease")
                        } else {
                            ButtonLabel(text: "Run DarkSword", icon: "ant")
                        }
                    }
                    .buttonStyle(FancyButtonStyle(color: mgr.dsfailed || mgr.vfsfailed ? .red : .purple))
                    .disabled(mgr.dsrunning || mgr.dsready)
                    
                    // fetch kernelcache
                    Button(action: {
                        guard !fetchingKcache else { return }
                        fetchingKcache = true

                        DispatchQueue.global(qos: .userInitiated).async {
                            let fetched = fetchkcache()

                            if fetched {
                                DispatchQueue.main.async {
                                    mgr.hasOffsets = true
                                    fetchingKcache = false
                                    Alertinator.shared.alert(title: "Successfully feteched kernelcache!", body: "Now, restart the app to finish setup and use dirtyZero.", showCancel: false, actionLabel: "Exit", action: { exitinator() })
                                }
                                return
                            }

                            let dlkc = dlkcache()

                            DispatchQueue.main.async {
                                mgr.hasOffsets = dlkc
                                if dlkc {
                                    Alertinator.shared.alert(title: "Successfully downloaded kernelcache!", body: "Now, restart the app to finish setup and use dirtyZero.", showCancel: false, actionLabel: "Exit", action: { exitinator() })
                                }
                                fetchingKcache = false
                            }
                        }
                    }) {
                        if fetchingKcache {
                            ButtonLabel(text: "Fetching Kernelcache...", icon: "showMeProgressPlease")
                        } else {
                            ButtonLabel(text: "Fetch Kernelcache", icon: "externaldrive")
                        }
                    }
                    .buttonStyle(FancyButtonStyle(color: mgr.dsfailed || mgr.vfsfailed ? .red : Color.accentColor))
                    .disabled(mgr.dsrunning || mgr.vfsrunning)
                } else {
                    Button(action: {
                        offsets_init()
                        mgr.run()
                    }) {
                        if mgr.dsfailed || mgr.vfsfailed {
                            ButtonLabel(text: "Exploit Failed!", icon: "xmark")
                        } else if mgr.dsrunning || mgr.vfsrunning {
                            ButtonLabel(text: "Running Exploit...", icon: "showMeProgressPlease")
                        } else {
                            ButtonLabel(text: "Run DarkSword", icon: "ant")
                        }
                    }
                    .buttonStyle(FancyButtonStyle(color: mgr.dsfailed || mgr.vfsfailed ? .red : .purple))
                    .disabled(mgr.dsrunning || mgr.vfsrunning || mgr.dsready)
                    
                    Button(action: {
                        mgr.vfsinit()
                    }) {
                        if mgr.vfsfailed {
                            ButtonLabel(text: "Initalize Failed!", icon: "xmark")
                        } else if mgr.vfsrunning {
                            ButtonLabel(text: "Initalizing VFS...", icon: "showMeProgressPlease")
                        } else {
                            ButtonLabel(text: "Initalize VFS", icon: "cpu")
                        }
                    }
                    .buttonStyle(FancyButtonStyle())
                    .disabled(!mgr.dsready || mgr.vfsrunning)
                }
            } else {
                Button(action: {
                    mgr.applyTweaks(tweakData: tweakArray)
                }) {
                    ButtonLabel(text: "Apply Tweaks", icon: "checkmark")
                }
                .buttonStyle(FancyButtonStyle(color: .green))
                .disabled(tweakArray.flatMap { $0.tweaks }.filter { $0.isOn }.isEmpty)
                HStack {
                    Button(action: {
                        mgr.revertTweaks()
                    }) {
                        ButtonLabel(text: "Revert", icon: "xmark")
                    }
                    .buttonStyle(FancyButtonStyle(color: .red))
                    Button(action: {
                        mgr.respringDevice()
                    }) {
                        ButtonLabel(text: "Respring", icon: "goforward")
                    }
                    .buttonStyle(FancyButtonStyle(color: .orange))
                }
            }
        }
    }
}

// this is annoying but whatever
struct RemoveSidebarToggle: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 17.0, *) {
            content
                .toolbar(removing: .sidebarToggle)
        } else {
            
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(dirtyZeroManager())
}
