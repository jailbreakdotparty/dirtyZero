//
//  CustomTweaksView.swift
//  dirtyZero
//
//  Created by Main on 10/10/25.
//

import SwiftUI
import PartyUI
import UIKit

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
    
    var body: some View {
        NavigationStack {
            List {
                Section(header: HeaderLabel(text: "Tweak Info", icon: "info.circle")) {
                    VStack(spacing: 10) {
                        TextField("Tweak Name", text: $tweakName)
                            .textFieldStyle(GlassyTextFieldStyle())
                        HStack {
                            TextField("/path/to/zero", text: $path2Add)
                                .textFieldStyle(GlassyTextFieldStyle())
                                .autocorrectionDisabled()
                                .textInputAutocapitalization(.never)
                            Button(action: {
                                path2Add = UIPasteboard.general.string ?? ""
                            }) {
                                Image(systemName: "doc.on.doc")
                                    .frame(width: 18, height: 24)
                            }
                            .buttonStyle(GlassyButtonStyle())
                            .frame(width: 50)
                            Button(action: {
                                if path2Add.isEmpty {
                                    Alertinator.shared.alert(title: "Invaild Path!", body: "Please enter a path and try again.")
                                } else {
                                    addPath()
                                }
                            }) {
                                Image(systemName: "plus")
                                    .frame(width: 18, height: 24)
                            }
                            .buttonStyle(GlassyButtonStyle())
                            .frame(width: 50)
                        }
                    }
                }
                .listRowSeparator(.hidden)
                
                Section(header: HeaderLabel(text: "Added Paths", icon: "pencil")) {
                    ForEach(targetPaths) { item in
                        HStack {
                            Text(item.path)
                            Spacer()
                            Button(action: {
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
                .listRowInsets(EdgeInsets(top: 6, leading: 18, bottom: 6, trailing: 18))
            }
            .listStyle(.plain)
            .navigationTitle("Create Tweak")
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
                OverlayButtonContainer(content: VStack {
                    Button(action: {
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
                })
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
