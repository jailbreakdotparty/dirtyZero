//
//  SettingsView.swift
//  dirtyZero
//
//  Created by lunginspector on 10/8/25.
//

import SwiftUI
import PartyUI
import DeviceKit

struct SettingsView: View {
    @EnvironmentObject var mgr: dirtyZeroManager
    @Environment(\.dismiss) var dismiss
    @Environment(\.openURL) var openURL
    @AppStorage("tweakArray") var tweakArray: [ZeroSection] = TweakArray.tweaks
    
    @AppStorage("useRespringApp") var useRespringApp: Bool = false
    @AppStorage("respringAppBID") var respringAppBID: String = "com.jbdotparty.respringr"
    
    @AppStorage("enableDebugSettings") var enableDebugSettings: Bool = false
    @AppStorage("enableRiskyTweaks") var enableRiskyTweaks: Bool = false
    
    @State private var fetchingKcache = false
    
    var body: some View {
        NavigationStack {
            List {
                Section(header: HeaderLabel(text: "Info", icon: "info.circle")) {
                    VStack {
                        AppInfoCell()
                            .frame(maxWidth: .infinity, alignment: .leading)
                        HStack {
                            Button(action: {
                                openURL(URL(string: "https://jailbreak.party/discord")!)
                            }) {
                                ButtonLabel(text: "Discord", icon: "discord", useImage: true)
                            }
                            .buttonStyle(TranslucentButtonStyle(color: .discord))
                            Button(action: {
                                openURL(URL(string: "https://github.com/jailbreakdotparty/dirtyZero")!)
                            }) {
                                ButtonLabel(text: "GitHub", icon: "github", useImage: true)
                            }
                            .buttonStyle(TranslucentButtonStyle(color: .gitHub))
                        }
                        Button(action: {
                            openURL(URL(string: "https://jailbreak.party")!)
                        }) {
                            ButtonLabel(text: "Website", icon: "globe")
                        }
                        .buttonStyle(TranslucentButtonStyle(color: .blue))
                    }
                    NavigationLink("Credits") {
                        List {
                            LinkCreditCell(image: Image("skadz108"), name: "Skadz", description: "Initial developer, backend, and exploit-related management.", url: "https://github.com/skadz108")
                            LinkCreditCell(image: Image("lunginspector"), name: "lunginspector", description: "Frontend developer, tweak creator, and app UI.", url: "https://github.com/lunginspector")
                            LinkCreditCell(image: Image("ianbeer"), name: "Ian Beer (Gooogle Project Zero)", description: "Discovering & publishing CVE-2025-24203.", url: "https://project-zero.issues.chromium.org/issues/391518636")
                            LinkCreditCell(image: Image("DuyTran"), name: "Duy Tran", description: "App detection exploit, and various contributions to other utilized libraries", url: "https://github.com/khanhduytran0")
                            if mgr.chosenExploit == .DarkSword {
                                LinkCreditCell(image: Image("rooootdev"), name: "rooootdev", description: "DarkSword exploit library and implementation assistance", url: "https://github.com/rooootdev")
                                LinkCreditCell(image: Image("appinstallerios"), name: "AppInstalleriOS", description: "Patchfinder assistance and numerous contributions", url: "https://github.com/AppInstalleriOSGH")
                                LinkCreditCell(image: Image("wh1te4ever"), name: "wh1te4ever", description: "Various additions and research to DarkSword exploit", url: "https://github.com/wh1te4ever")
                                LinkCreditCell(image: Image("opa334"), name: "opa334", description: "Original DarkSword kernel exploit implementation, and various required libraries", url: "https://github.com/opa334")
                                LinkCreditCell(image: Image("alfiecg"), name: "Alfie CG", description: "Developed kernelcache downloading library", url: "https://github.com/alfiecg24")
                            }
                            LinkCreditCell(image: Image("neonmodder123"), name: "neonmodder123", description: "Developed WebView respring method.", url: "https://github.com/neonmodder123")
                        }
                        .navigationTitle("Credits")
                    }
                }
                Section(header: HeaderLabel(text: "Exploits", icon: "ant"), footer: Text("To fetch kernelcache, you should run the exploit first, and then click the \"Fetch Kernelcache\" button.")) {
                    VStack {
                        if mgr.supportsl0ckwire {
                            Picker("", selection: $mgr.chosenExploit) {
                                ForEach(ExploitOptions.allCases, id: \.self) { option in
                                    if option.rawValue != "none" {
                                        Text(option.rawValue).tag(option)
                                    }
                                }
                            }
                            .pickerStyle(.segmented)
                            .listRowSeparator(.hidden)
                        }
                        // this check should keep the ux of hiding these options for devices that support both l0ckwire and DarkSword, while also forcing these options to be shown if this device supports only DarkSword.
                        if mgr.chosenExploit == .DarkSword || defaultExploit() == .DarkSword {
                            if !mgr.hasOffsets {
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
                                .buttonStyle(TranslucentButtonStyle())
                                .disabled(fetchingKcache)
                            } else {
                                Button(role: .destructive, action: {
                                    clearkerncachedata()
                                    mgr.hasOffsets = false
                                }) {
                                    ButtonLabel(text: "Delete Kernelcache", icon: "trash")
                                }
                                .buttonStyle(TranslucentButtonStyle(color: .red))
                            }
                        }
                    }
                    
                    if mgr.chosenExploit == .DarkSword {
                        NavigationLink("Modify Offsets", destination: OffsetManagementView())
                    }
                }
                Section(header: HeaderLabel(text: "Applying", icon: "checkmark.seal")) {
                    Toggle(isOn: $useRespringApp) {
                        Text("Use Respring App")
                        Text("Only enable this if you prefer using a [seperate app](https://github.com/jailbreakdotparty/dirtyZero/releases/tag/respringr) to respring your device.")
                    }
                    if useRespringApp {
                        TextField("Respring App BID", text: $respringAppBID)
                    }
                }
                Section(header: HeaderLabel(text: "Customizaton", icon: "checklist")) {
                    Toggle("Debug Settings", isOn: $enableDebugSettings)
                    Toggle("Risky Tweaks", isOn: $enableRiskyTweaks)
                }
                Section(header: HeaderLabel(text: "Data", icon: "externaldrive")) {
                    VStack {
                        Button(action: {
                            tweakArray = TweakArray.tweaks
                        }) {
                            ButtonLabel(text: "Reset Selected Tweaks", icon: "checklist")
                        }
                        .buttonStyle(TranslucentButtonStyle())
                        Button(action: {
                            Alertinator.shared.alert(title: "Are you sure you'd like to remove all your tweaks?", body: "This will remove every tweak that you have created.", action: {
                                let customTweaksIndex = tweakArray.firstIndex(where: { $0.name == "Custom Tweaks" }) ?? 0
                                
                                tweakArray[customTweaksIndex].tweaks.removeAll()
                            })
                        }) {
                            ButtonLabel(text: "Remove Custom Tweaks", icon: "trash")
                        }
                        .buttonStyle(TranslucentButtonStyle(color: .red))
                    }
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                    }
                }
            }
        }
    }
}

#Preview {
    SettingsView()
}
