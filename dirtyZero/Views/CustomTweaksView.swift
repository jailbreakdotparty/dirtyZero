//
//  CustomTweaksView.swift
//  dirtyZero
//
//  Created by Main on 10/10/25.
//

import SwiftUI
import PartyUI
import UIKit
import DeviceKit

// i fucking hate this. but it makes it work so please don't change this.
// Skadz, 10/11/25 7:17 PM
struct PathItem: Identifiable, Hashable {
    let id = UUID()
    var path: String
}

struct CustomTweaksView: View {
    @State private var tweakName: String = ""
    @State private var targetPaths: [PathItem] = []
    @State private var path2Add: String = ""
    
    @Environment(\.dismiss) private var dismiss
    @AppStorage("customTweaks") private var customTweaks: [ZeroTweak] = []
    
    let device = Device.current
    
    var body: some View {
        NavigationStack {
            List {
                Section(header: HeaderLabel(text: "Tweak Info", icon: "info.circle")) {
                    VStack(spacing: 10) {
                        TextField("Tweak Name", text: $tweakName)
                            .textFieldStyle(GlassyTextFieldStyle())
                        HStack {
                            GlassyTextButtonField(titleKey: "/path/to/zero", text: $path2Add, useAutoCorrection: false, useAutoCaptialization: false, button: Group {
                                Button(action: {
                                    Haptic.shared.play(.soft)
                                    path2Add = UIPasteboard.general.string ?? ""
                                }) {
                                    Image(systemName: "doc.on.doc")
                                        .frame(width: 18, height: 24)
                                }
                            })
                            Button(action: {
                                Haptic.shared.play(.soft)
                                addPath()
                            }) {
                                Image(systemName: "plus")
                                    .frame(height: 24)
                            }
                            .buttonStyle(GlassyButtonStyle(isDisabled: path2Add.isEmpty || tweakName.isEmpty, useFullWidth: false))
                        }
                    }
                }
                .listRowSeparator(.hidden)
                .listRowInsets(.dropdownRowInsets)
                
                Section(header: HeaderLabel(text: "Added Paths", icon: "pencil")) {
                    ForEach(targetPaths) { item in
                        HStack {
                            Text(item.path)
                            Spacer()
                            Button(action: {
                                Haptic.shared.play(.soft)
                                withAnimation {
                                    targetPaths.removeAll { $0.id == item.id }
                                }
                            }) {
                                Image(systemName: "xmark")
                            }
                            .buttonStyle(.plain)
                        }
                        .modifier(GlassyListRowBackground())
                    }
                }
                .listRowSeparator(.hidden)
                .listRowInsets(.dropdownRowInsets)
            }
            .listStyle(.plain)
            .navigationTitle("Create Tweak")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                VStack {
                    Button(action: {
                        Haptic.shared.play(.soft)
                        if tweakName.isEmpty || targetPaths.isEmpty {
                            Alertinator.shared.alert(title: "No paths were added!", body: "Add some paths & set a tweak name, then try again.")
                        } else {
                            var tweakPaths: [String] = []
                            for item in targetPaths {
                                tweakPaths.append(item.path)
                            }
                            let newCustomTweak = ZeroTweak(icon: "paintbrush.pointed", name: tweakName, minSupportedVersion: 16.0, maxSupportedVersion: 18.9, paths: tweakPaths)
                            customTweaks.append(newCustomTweak)
                            dismiss()
                        }
                    }) {
                        ButtonLabel(text: "Add Tweak", icon: "plus")
                    }
                    .buttonStyle(GlassyButtonStyle(color: tweakName.isEmpty || targetPaths.isEmpty ? .gray : .accentColor, isMaterialButton: true))
                }
                .modifier(OverlayBackground(stickBottomPadding: device.isPad ? true : false))
            }
        }
        .tint(.purple)
    }
    
    private func addPath() {
        withAnimation {
            targetPaths.append(PathItem(path: path2Add))
            path2Add = ""
        }
    }
    
    private func deletePath(at offsets: IndexSet) {
        withAnimation {
            targetPaths.remove(atOffsets: offsets)
        }
    }
}

#Preview {
    CustomTweaksView()
}
