//
//  CustomTweaksView.swift
//  dirtyZero
//
//  Created by Main on 10/10/25.
//

import SwiftUI
import UIKit

struct CustomZeroTweak: Identifiable, Codable {
    var id: String { name }
    var name: String
    var paths: [String]
    
    enum CodingKeys: String, CodingKey {
        case name, paths
    }
}

struct CustomTweaksView: View {
    @State private var customTweakPath: String = ""
    @State private var customTweakName: String = ""
    @State private var customTweakPaths: [String] = []
    
    @AppStorage("customTweaks") private var customTweaks: [CustomZeroTweak] = []
    @AppStorage("customEnabledTweaks") private var enabledCustomTweakIds: [String] = []
    
    private var enabledCustomTweaks: [CustomZeroTweak] {
        customTweaks.filter { tweak in enabledCustomTweakIds.contains(tweak.id) }
    }
    
    private func isCustomTweakEnabled(_ tweak: CustomZeroTweak) -> Bool {
        enabledCustomTweakIds.contains(tweak.id)
    }
    
    private func toggleCustomTweak(_ tweak: CustomZeroTweak) {
        if isCustomTweakEnabled(tweak) {
            enabledCustomTweakIds.removeAll { $0 == tweak.id }
        } else {
            enabledCustomTweakIds.append(tweak.id)
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading) {
                    Section(header: HeaderStyle(label: "Create Tweak", icon: "wrench.and.screwdriver")) {
                        VStack(alignment: .leading) {
                            HStack {
                                HStack(spacing: 10) {
                                    if customTweakName.isEmpty {
                                        Image(systemName: "character.cursor.ibeam")
                                            .frame(width: 24, alignment: .center)
                                            .opacity(0.25)
                                    } else {
                                        Image(systemName: "character.cursor.ibeam")
                                            .frame(width: 24, alignment: .center)
                                            .foregroundStyle(.orange)
                                    }
                                    TextField("Tweak Name", text: $customTweakName)
                                        .foregroundStyle(.orange)
                                }
                                .padding(13)
                                .frame(maxWidth: .infinity)
                                .background(.orange.opacity(0.2))
                                .cornerRadius(12)
                            }
                            HStack {
                                HStack {
                                    HStack(spacing: 10) {
                                        if customTweakPath.isEmpty {
                                            Image(systemName: "folder")
                                                .frame(width: 24, alignment: .center)
                                                .opacity(0.25)
                                        } else {
                                            Image(systemName: "folder")
                                                .frame(width: 24, alignment: .center)
                                                .foregroundStyle(.orange)
                                        }
                                        TextField("Custom Path", text: $customTweakPath)
                                            .foregroundStyle(.orange)
                                    }
                                    .padding(13)
                                    .frame(maxWidth: .infinity)
                                    .background(.orange.opacity(0.2))
                                    .cornerRadius(12)
                                    RegularButtonStyle(text: "", icon: "doc.on.clipboard", isPNGIcon: false, disabled: false, foregroundStyle: .orange, action: {
                                        if let clipboardText = UIPasteboard.general.string {
                                            customTweakPath = clipboardText
                                        } else {
                                            Alertinator.shared.alert(title: "No Clipboard Contents Found!", body: "Please copy a vaild path.")
                                        }
                                    }).frame(width: 50)
                                    RegularButtonStyle(text: "", icon: "plus", isPNGIcon: false, disabled: false, foregroundStyle: .orange, action: {
                                        customTweakPaths.append(customTweakPath)
                                        customTweakPath = ""
                                    }).frame(width: 50)
                                }
                            }
                            VStack(alignment: .leading) {
                                HStack {
                                    VStack(alignment: .leading) {
                                        HStack {
                                            Image(systemName: "wrench.and.screwdriver")
                                                .frame(width: 24, alignment: .center)
                                            Text(customTweakName.isEmpty ? "No Name" : customTweakName)
                                        }
                                        Text(customTweakPaths.isEmpty ? "No Paths" : customTweakPaths.joined(separator: ", "))
                                            .multilineTextAlignment(.leading)
                                    }
                                    Spacer()
                                    RegularButtonStyle(text: "", icon: "xmark", isPNGIcon: false, disabled: false, foregroundStyle: .red, action: {
                                        customTweakName = ""
                                        customTweakPath = ""
                                        customTweakPaths = []
                                    }).frame(width: 50)
                                }
                            }
                            .foregroundStyle(.orange)
                            .padding(13)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(.orange.opacity(0.2))
                            .cornerRadius(14)
                            RegularButtonStyle(text: "Add Tweak", icon: "plus", isPNGIcon: false, disabled: false, foregroundStyle: .green, action: {
                                if customTweakName.isEmpty || customTweakPaths.isEmpty {
                                    Alertinator.shared.alert(title: "Invaild Tweak Details!", body: "Please fill out all the fields properly.")
                                } else {
                                    let newTweak = CustomZeroTweak(name: customTweakName, paths: customTweakPaths)
                                    customTweaks.append(newTweak)
                                    customTweakName = ""
                                    customTweakPath = ""
                                    customTweakPaths = []
                                }
                            })
                        }
                    }
                    .padding(.horizontal, 20)
                    CustomTweakList(tweaks: $customTweaks, enabledCustomTweakIds: $enabledCustomTweakIds)
                }
            }
            .listStyle(.plain)
            .navigationTitle("Custom Tweaks")
            .safeAreaInset(edge: .bottom) {
                VStack {
                    if enabledCustomTweaks.isEmpty {
                        RegularButtonStyle(text: "Apply Tweaks", icon: "checkmark", isPNGIcon: false, disabled: false, foregroundStyle: .gray, action: {
                            Alertinator.shared.alert(title: "No Tweaks Enabled!", body: "Please select some tweaks first.")
                        })
                    } else {
                        RegularButtonStyle(text: "Apply Tweaks", icon: "checkmark", isPNGIcon: false, disabled: false, foregroundStyle: .green, action: {
                            applyCustomTweaks(tweaks: enabledCustomTweaks)
                        })
                    }
                }
                .padding(.horizontal, 25)
                .padding(.top, 50)
                .background(
                    ZStack {
                        Rectangle()
                            .foregroundStyle(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color.clear,
                                        Color(.systemBackground).opacity(0.7)
                                    ]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                        VariableBlurView(maxBlurRadius: 8, direction: .blurredBottomClearTop)
                    }
                    .ignoresSafeArea()
                )
            }
        }
    }
    
    func applyCustomTweaks(tweaks: [CustomZeroTweak]) {
        var applyingString = "[*] Applying the selected tweaks: "
        let tweakNames = enabledCustomTweaks.map { $0.name }.joined(separator: ", ")
        applyingString += tweakNames
        
        print(applyingString)
        
        let totalTweaks = enabledCustomTweaks.count
        var currentTweak = 1
        
        do {
            for tweak in enabledCustomTweaks {
                print("[\(currentTweak)/\(totalTweaks)] Applying \(tweak.name)...")
                for path in tweak.paths {
                    try zeroPoC(path: path)
                }
                print("[*] Applied tweak \(currentTweak)/\(totalTweaks)!")
                currentTweak += 1
            }
            print("[*] Successfully applied all tweaks!")
            Alertinator.shared.alert(title: "Tweaks Applied Successfully!", body: "\(totalTweaks)/\(totalTweaks) tweaks applied! If you'd like to respring, ensure you have RespringApp installed.")
        } catch {
            print("[!] \(error)")
            Alertinator.shared.alert(title: "Failed to Apply", body: "There was an error while applying tweak \(currentTweak)/\(totalTweaks): \(error).")
            return
        }
    }
}
