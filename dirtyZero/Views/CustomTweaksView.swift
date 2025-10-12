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
            VStack {
                List {
                    Section(header: HeaderStyle(label: "Tweak Info", icon: "info.circle")) {
                        TextField("Tweak Name", text: $tweakName)
                            .multilineTextAlignment(.leading)
                            .padding()
                            .background(Color(.quaternarySystemFill))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    
                    Section(header: HeaderStyle(label: "Target Paths", icon: "pencil")) {
                        ForEach(targetPaths) { item in
                            HStack {
                                Text(item.path)
                                    .font(.system(size: 12, weight: .regular, design: .monospaced))
                                    .multilineTextAlignment(.leading)
                                    .padding()
                                    .background(Color(.quaternarySystemFill))
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                
                                Button(action: {
                                    withAnimation {
                                        targetPaths.removeAll { $0.id == item.id }
                                    }
                                }) {
                                    Image(systemName: "minus.circle.fill")
                                        .font(.title2)
                                }
                                
                                Spacer()
                            }
                        }
                        HStack {
                            TextField("/path/to/zero", text: $path2Add)
                                .multilineTextAlignment(.leading)
                                .padding()
                                .background(Color(.quaternarySystemFill))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            
                            Button(action: addPath) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title2)
                            }
                            .disabled(path2Add.isEmpty)
                        }
                    }
                    
                    RegularButtonStyle(text: "Add Tweak", icon: "plus.circle.fill", isPNGIcon: false, disabled: targetPaths.isEmpty, foregroundStyle: .green, action: {
                        var tweakPaths: [String] = []
                        for item in targetPaths {
                            tweakPaths.append(item.path)
                        }
                        let newCustomTweak = ZeroTweak(icon: "paintbrush.pointed", name: tweakName, minSupportedVersion: 16.0, maxSupportedVersion: 19.0, paths: tweakPaths)
                        customTweaks.append(newCustomTweak)
                        dismiss()
                    })
                }
                .listStyle(.plain)
            }
            .navigationTitle("Create Tweak")
            .navigationBarTitleDisplayMode(.inline)
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
