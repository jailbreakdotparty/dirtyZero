//
//  SettingsView.swift
//  dirtyZero
//
//  Created by Main on 10/8/25.
//

import SwiftUI
import DeviceKit

struct SettingsView: View {
    @AppStorage("showLogs") var showLogs: Bool = true
    @AppStorage("showDebugSettings") var showDebugSettings: Bool = false
    @AppStorage("showRiskyTweaks") var showRiskyTweaks: Bool = false
    @Environment(\.openURL) var openURL
    
    var body: some View {
        NavigationStack {
            VStack {
                List {
                    Section(header: HStack {
                        Image(systemName: "info.circle")
                        Text("About")
                    }) {
                        VStack {
                            HStack(spacing: 14) {
                                Image("dirtyZero")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 60, height: 60)
                                    .cornerRadius(14)
                                VStack(alignment: .leading) {
                                    Text("dirtyZero")
                                        .font(.system(.title2, weight: .semibold))
                                    Text("Version \(UIApplication.appVersion!) (\(weOnADebugBuild ? "Debug" : "Release"))")
                                        .font(.callout)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            VStack {
                                RegularButtonStyle(text: "Website", icon: "globe", isPNGIcon: false, disabled: false, foregroundStyle: .blue, action: {
                                    openURL(URL(string: "https://jailbreak.party")!)
                                })
                                HStack {
                                    RegularButtonStyle(text: "Discord", icon: "discord", isPNGIcon: true, disabled: false, foregroundStyle: .discord, action: {
                                        openURL(URL(string: "https://jailbreak.party/discord")!)
                                    })
                                    RegularButtonStyle(text: "GitHub", icon: "github", isPNGIcon: true, disabled: false, foregroundStyle: .gitHub, action: {
                                        openURL(URL(string: "https://github.com/jailbreakdotparty/dirtyZero")!)
                                    })
                                }
                            }
                        }
                        .listRowInsets(EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16))
                    }
                    
                    Section(header: HStack {
                        Image(systemName: "star")
                        Text("Credits")
                    }) {
                        CreditsRow(imageAssetName: "skadz108", name: "Skadz", contribution: "Original creator, backend developer.", socialURL: "https://github.com/skadz108")
                        CreditsRow(imageAssetName: "lunginspector", name: "lunginspector", contribution: "User interface, tweak creator.", socialURL: "https://github.com/lunginspector")
                    }
                    
                    Section(header: HStack {
                        Image(systemName: "gearshape")
                        Text("Settings")
                    }) {
                        if !weOnADebugBuild {
                            Toggle("Show Risky Tweaks", isOn: $showRiskyTweaks)
                            Toggle("Show Debug Settings", isOn: $showDebugSettings)
                        }
                        Toggle("Show Logs", isOn: $showLogs)
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}

struct CreditsRow: View {
    @Environment(\.openURL) private var openURL
    let imageAssetName: String
    let name: String
    let contribution: String
    let socialURL: String
    
    var body: some View {
        Button(action: {
            openURL(URL(string: socialURL)!)
        }) {
            HStack {
                Image(imageAssetName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 48, height: 48)
                    .clipShape(.rect(cornerRadius: 8))
                
                VStack {
                    HStack {
                        Text("**\(name)**")
                        Spacer()
                    }
                    HStack {
                        Text(contribution)
                            .foregroundStyle(.secondary)
                        Spacer()
                    }
                }
            }
        }
        .foregroundStyle(.primary)
    }
}
