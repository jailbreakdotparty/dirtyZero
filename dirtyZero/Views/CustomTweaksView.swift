//
//  CustomTweaksView.swift
//  dirtyZero
//
//  Created by Main on 10/10/25.
//

import SwiftUI
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
            ScrollView {
                VStack(alignment: .leading) {
                    Section(header: HeaderStyle(label: "Tweak Info", icon: "info.circle")) {
                        TextField("Tweak Name", text: $tweakName)
                            .multilineTextAlignment(.leading)
                            .padding(13)
                            .background(Color(.quaternarySystemFill))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    Section(header: HeaderStyle(label: "Target Paths", icon: "pencil")) {
                        VStack(spacing: 14) {
                            HStack {
                                TextField("/path/to/zero", text: $path2Add)
                                    .multilineTextAlignment(.leading)
                                    .padding(13)
                                    .background(Color(.quaternarySystemFill))
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                RegularButtonStyle(text: "", icon: "doc.on.doc", isPNGIcon: false, disabled: false, foregroundStyle: .purple, action: {
                                    if let clipboardText = UIPasteboard.general.string {
                                        path2Add = clipboardText
                                    } else {
                                        Alertinator.shared.alert(title: "Warning!", body: "No clipboard contents found!")
                                    }
                                }).frame(width: 50)
                                RegularButtonStyle(text: "", icon: "plus.circle.fill", isPNGIcon: false, disabled: path2Add.isEmpty, foregroundStyle: .purple, action: addPath).frame(width: 50)
                            }
                            ForEach(targetPaths) { item in
                                HStack {
                                    Text(item.path)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .multilineTextAlignment(.leading)
                                        .foregroundStyle(.purple)
                                        .font(.system(.body, design: .monospaced))
                                        .multilineTextAlignment(.leading)
                                        .padding(13)
                                        .background(.purple.opacity(0.2))
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                    
                                    Button(action: {
                                        withAnimation {
                                            targetPaths.removeAll { $0.id == item.id }
                                        }
                                    }) {
                                        Image(systemName: "minus.circle.fill")
                                            .font(.title2)
                                            .foregroundStyle(.purple)
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .navigationTitle("Create Tweak")
                .navigationBarTitleDisplayMode(.inline)
            }
            .safeAreaInset(edge: .bottom) {
                VStack {
                    RegularButtonStyle(text: "Add Tweak", icon: "plus.circle.fill", isPNGIcon: false, disabled: targetPaths.isEmpty || tweakName.isEmpty, foregroundStyle: .green, action: {
                        var tweakPaths: [String] = []
                        for item in targetPaths {
                            tweakPaths.append(item.path)
                        }
                        let newCustomTweak = ZeroTweak(icon: "paintbrush.pointed", name: tweakName, minSupportedVersion: 16.0, maxSupportedVersion: 18.9, paths: tweakPaths)
                        customTweaks.append(newCustomTweak)
                        dismiss()
                    })
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
                    }.ignoresSafeArea()
                )
            }
        }
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
