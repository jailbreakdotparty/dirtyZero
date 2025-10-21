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
    @AppStorage("autoRespringOnApply") var autoRespringOnApply: Bool = false
    @AppStorage("respringBundle") var respringBundle: String = "com.respring.app"
    @Environment(\.openURL) var openURL
    
    var body: some View {
        NavigationStack {
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
                            Button(action: {
                                Haptic.shared.play(.soft)
                                openURL(URL(string: "https://jailbreak.party")!)
                            }) {
                                HStack {
                                    Image(systemName: "globe")
                                        .frame(width: 22, height: 22, alignment: .center)
                                    Text("Website")
                                }
                            }
                            .buttonStyle(SettingsButtonStyle(color: .blue, isDisabled: false))
                            HStack {
                                Button(action: {
                                    Haptic.shared.play(.soft)
                                    openURL(URL(string: "https://jailbreak.party/discord")!)
                                }) {
                                    HStack {
                                        Image("discord")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(maxWidth: 22, maxHeight: 22)
                                        Text("Discord")
                                    }
                                }
                                .buttonStyle(SettingsButtonStyle(color: .discord, isDisabled: false))
                                Button(action: {
                                    Haptic.shared.play(.soft)
                                    openURL(URL(string: "https://github.com/jailbreakdotparty/dirtyZero")!)
                                }) {
                                    HStack {
                                        Image("github")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(maxWidth: 22, maxHeight: 22)
                                        Text("GitHub")
                                    }
                                }
                                .buttonStyle(SettingsButtonStyle(color: .gitHub, isDisabled: false))
                            }
                        }
                    }
                }
                .listRowInsets(EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16))
                
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
                    Toggle("Auto Respring on Apply", isOn: $autoRespringOnApply)
                }
                Section(header: HStack {
                    Image(systemName: "gearshape")
                    Text("RespringApp Bundle ID")
                }) {
                    TextField("RespringApp Bundle ID:", text: $respringBundle)
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
