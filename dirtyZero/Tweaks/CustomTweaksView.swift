//
//  CustomTweaksView.swift
//  dirtyZero
//
//  Created by lunginspector on 10/10/25.
//

import SwiftUI
import PartyUI
import UIKit

struct CustomTweaksView: View {
    @EnvironmentObject var mgr: dirtyZeroManager
    @Environment(\.dismiss) var dismiss
    
    @AppStorage("tweakArray") var tweakArray: [ZeroSection] = TweakArray.tweaks
    @AppStorage("enableDebugSettings") var enableDebugSettings: Bool = false
    
    @State private var tweakName: String = ""
    @State private var path2Add: String = ""
    @State private var targetPaths: [String] = []
    
    var body: some View {
        NavigationStack {
            List {
                if enableDebugSettings {
                    Section {
                        Button(action: {
                            tweakName = "Hide Dock Background"
                            targetPaths = ["/System/Library/PrivateFrameworks/CoreMaterial.framework/dockDark.materialrecipe", "/System/Library/PrivateFrameworks/CoreMaterial.framework/dockLight.materialrecipe"]
                        }) {
                            ButtonLabel(text: "Populate Fields", icon: "character.cursor.ibeam")
                        }
                        .buttonStyle(TranslucentButtonStyle(color: .purple))
                    } header: {
                        HeaderLabel(text: "Debug", icon: "ant")
                    }
                    .listRowInsets(.sectionInsets)
                    .listRowSeparator(.hidden)
                }
                
                Section {
                    VStack {
                        TextField("Tweak Name", text: $tweakName)
                            .modifier(TextFieldBackground())
                        
                        HStack {
                            TextField("/path/to/zero", text: $path2Add)
                                .modifier(TextFieldBackground())
                            
                            Button {
                                if targetPaths.contains(path2Add) {
                                    Haptic.shared.play(.heavy)
                                    Alertinator.shared.alert(title: "Error!", body: "That path matches one or more paths that you have already included as a target path. Please try a different path.")
                                } else {
                                    Haptic.shared.play(.soft)
                                    targetPaths.append(path2Add)
                                }
                            } label: {
                                Image(systemName: "plus")
                                    .frame(width: 24, height: 24)
                            }
                            .buttonStyle(TranslucentButtonStyle(color: .purple, useFullWidth: false))
                            .disabled(path2Add.isEmpty || tweakName.isEmpty)
                        }
                    }
                } header: {
                    HeaderLabel(text: "Create Tweak", icon: "paintbrush")
                }
                .listRowInsets(.sectionInsets)
                .listRowSeparator(.hidden)
                
                if !targetPaths.isEmpty {
                    Section {
                        ForEach(targetPaths, id: \.self) { path in
                            Text(path)
                                .font(.system(.footnote, design: .monospaced))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding()
                                .background(Color(.secondarySystemBackground), in: .rect(cornerRadius: cornerRad.component))
                                .swipeActions {
                                    Button(role: .destructive) {
                                        targetPaths.removeAll { $0 == path }
                                    } label: {
                                        Image(systemName: "trash")
                                    }
                                    .tint(.red)
                                }
                        }
                    } header: {
                        HeaderLabel(text: "Target Paths", icon: "character.cursor.ibeam")
                    }
                    .listRowInsets(.sectionInsets)
                    .listRowSeparator(.hidden)
                }
            }
            .listStyle(.plain)
            .navigationTitle("Tweak Creator")
            .navigationBarTitleDisplayMode(.inline)
            .safeAreaInset(edge: .bottom) {
                Button {
                    Haptic.shared.play(.soft)
                    let customTweaksIndex = tweakArray.firstIndex(where: { $0.name == "Custom Tweaks" }) ?? 0
                    tweakArray[customTweaksIndex].tweaks.append(ZeroTweak(name: tweakName, icon: "paintbrush", paths: targetPaths))
                    dismiss()
                } label: {
                    ButtonLabel(text: "Add Tweak", icon: "plus")
                }
                .buttonStyle(FancyButtonStyle(color: .purple))
                .disabled(targetPaths.isEmpty || tweakName.isEmpty)
                .modifier(OverlayBackground(stickBottomPadding: UIDevice.current.userInterfaceIdiom == .pad))
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        CloseSheetLabel("Cancel")
                    }
                }
            }
            .tint(.purple)
        }
    }
}

#Preview {
    CustomTweaksView()
}
