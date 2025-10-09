//
//  SettingsView.swift
//  dirtyZero
//
//  Created by Main on 10/8/25.
//

import SwiftUI
import DeviceKit

struct SettingsView: View {
    @Binding var showDebugSettings: Bool
    @Binding var showLogs: Bool
    @Binding var showRiskyTweaks: Bool
    @Binding var hasShownWelcome: Bool
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
                        HStack {
                            RegularButtonStyle(text: "Discord", icon: "message", useMaxHeight: false, disabled: false, foregroundStyle: .blue, action: {
                                openURL(URL(string: "https://jailbreak.party/discord")!)
                            })
                            RegularButtonStyle(text: "GitHub", icon: "apple.terminal", useMaxHeight: false, disabled: false, foregroundStyle: .green, action: {
                                openURL(URL(string: "https://github.com/jailbreakdotparty/dirtyZero")!)
                            })
                        }
                    }
                    .listRowInsets(EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16))
                }
                Section(header: HStack {
                    Image(systemName: "gearshape")
                    Text("Settings")
                }) {
                    if !weOnADebugBuild {
                        Toggle("Show Risky Tweaks", isOn: $showRiskyTweaks)
                        Toggle("Show Debug Settings", isOn: $showDebugSettings)
                    }
                    if #available(iOS 17.0, *) {
                        Toggle("Show Logs", isOn: $showLogs)
                            .onChange(of: showLogs) {
                                hasShownWelcome = false
                            }
                    } else {
                        Toggle("Show Logs", isOn: $showLogs)
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}
