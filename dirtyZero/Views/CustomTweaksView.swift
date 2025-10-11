//
//  CustomTweaksView.swift
//  dirtyZero
//
//  Created by Main on 10/10/25.
//

import SwiftUI

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
    
    @FocusState private var isCustomPathFieldFocused: Bool
    @FocusState private var isCustomNameFieldFocused: Bool
    
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
            List {
                Section(header: HeaderStyle(label: "Custom Paths", icon: "terminal")) {
                    VStack(alignment: .leading) {
                        HStack {
                            HStack(spacing: 10) {
                                if customTweakPath.isEmpty {
                                    Image(systemName: "terminal")
                                        .opacity(0.25)
                                } else {
                                    Image(systemName: "terminal")
                                        .foregroundStyle(.accent)
                                }
                                TextField("Custom Path", text: $customTweakPath, axis: .vertical)
                                    .foregroundStyle(.accent)
                            }
                            .padding(13)
                            .frame(maxWidth: .infinity)
                            .background(.accent.opacity(0.2))
                            .cornerRadius(12)
                            .focused($isCustomPathFieldFocused)
                            if isCustomPathFieldFocused {
                                RegularButtonStyle(text: "", icon: "xmark", isPNGIcon: false, disabled: false, foregroundStyle: .red, action: {
                                    isCustomPathFieldFocused = false
                                }).frame(width: 50)
                            }
                        }
                        HStack {
                            HStack(spacing: 10) {
                                if customTweakName.isEmpty {
                                    Image(systemName: "terminal")
                                        .opacity(0.25)
                                } else {
                                    Image(systemName: "terminal")
                                        .foregroundStyle(.accent)
                                }
                                TextField("Tweak Name", text: $customTweakName, axis: .vertical)
                                    .foregroundStyle(.accent)
                            }
                            .padding(13)
                            .frame(maxWidth: .infinity)
                            .background(.accent.opacity(0.2))
                            .cornerRadius(12)
                            .focused($isCustomNameFieldFocused)
                            if isCustomNameFieldFocused {
                                RegularButtonStyle(text: "", icon: "xmark", isPNGIcon: false, disabled: false, foregroundStyle: .red, action: {
                                    isCustomNameFieldFocused = false
                                }).frame(width: 50)
                            }
                        }
                        HStack {
                            RegularButtonStyle(text: "", icon: "checkmark", isPNGIcon: false, disabled: false, foregroundStyle: .green, action: {
                                if customTweakPath.isEmpty {
                                    Alertinator.shared.alert(title: "Invaild Path", body: "Please enter a vaild path.")
                                } else {
                                    try? zeroPoC(path: customTweakPath)
                                    Alertinator.shared.alert(title: "Attempted to Zero", body: "Attempted to zero out \(customTweakPath)")
                                }
                            })
                            RegularButtonStyle(text: "", icon: "doc.on.clipboard", isPNGIcon: false, disabled: false, foregroundStyle: .accent, action: {
                                if let clipboardText = UIPasteboard.general.string {
                                    customTweakPath = clipboardText
                                } else {
                                    print("[!] epic pasteboard fail :fire:")
                                }
                            })
                            // This button just adds the path to the entire tweak.
                            RegularButtonStyle(text: "", icon: "plus", isPNGIcon: false, disabled: false, foregroundStyle: .accent, action: {
                                customTweakPaths.append(customTweakPath)
                                customTweakPath = ""
                            })
                        }
                        Text(customTweakPaths.rawValue)
                        RegularButtonStyle(text: "Add Tweak", icon: "plus", isPNGIcon: false, disabled: false, foregroundStyle: .green, action: {
                            if customTweakName.isEmpty || customTweakPaths.isEmpty {
                                Alertinator.shared.alert(title: "You stupid neckhurt!", body: "Please fill out all the fields properly.")
                            } else {
                                let newTweak = CustomZeroTweak(name: customTweakName, paths: customTweakPaths)
                                customTweaks.append(newTweak)
                            }
                        })
                    }
                }
                
                CustomTweakList(tweaks: customTweaks, enabledCustomTweakIds: $enabledCustomTweakIds)
                
                RegularButtonStyle(text: "Apply Tweaks", icon: "plus", isPNGIcon: false, disabled: false, foregroundStyle: .accent, action: {
                    applyCustomTweaks(tweaks: enabledCustomTweaks)
                })
            }
            .listStyle(.plain)
            .navigationTitle("Custom Tweaks")
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
