//
//  TweakInfoView.swift
//  dirtyZero
//
//  Created by lunginspector on 4/17/26.
//

import SwiftUI
import PartyUI

struct TweakInfoView: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var isTweakSupported: Bool
    
    var tweak: ZeroTweak
    
    let version = doubleSystemVersion()
    
    init(tweak: ZeroTweak, isTweakSupported: Bool = false) {
        self.tweak = tweak
        if version >= tweak.minSupportedVersion && version <= tweak.maxSupportedVersion {
            self.isTweakSupported = true
        } else {
            self.isTweakSupported = false
        }
    }
    
    var body: some View {
        NavigationStack {
            List {
                Section(header: HeaderLabel(text: "Tweak Info", icon: "info.circle")) {
                    VStack(alignment: .leading) {
                        HStack {
                            Image(systemName: tweak.icon)
                            Text(tweak.name)
                        }
                        
                        HStack {
                            HStack {
                                Image(systemName: isTweakSupported ? "checkmark.seal" : "xmark.seal")
                                Text(isTweakSupported ? "Supported" : "Not Supported")
                            }
                            .font(.callout)
                            .foregroundStyle(isTweakSupported ? .green : .red)
                            .padding(8)
                            .background(isTweakSupported ? .green.opacity(0.2) : .red.opacity(0.2), in: .capsule)
                            
                            HStack {
                                Image(systemName: "arrow.up")
                                Text(tweak.maxSupportedVersion.description)
                            }
                            .font(.callout)
                            .foregroundStyle(.secondary)
                            .padding(8)
                            .background(Color(.tertiarySystemBackground), in: .capsule)
                            
                            HStack {
                                Image(systemName: "arrow.down")
                                Text(tweak.minSupportedVersion.description)
                            }
                            .font(.callout)
                            .foregroundStyle(.secondary)
                            .padding(8)
                            .background(Color(.tertiarySystemBackground), in: .capsule)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .modifier(SectionPlatter())
                    .listRowSeparator(.hidden)
                    .listRowInsets(.sectionInsets)
                }
                Section(header: HeaderLabel(text: "Target Paths", icon: "character.cursor.ibeam")) {
                    ForEach(tweak.paths, id: \.self) { path in
                        Text(path)
                            .font(.system(.footnote, design: .monospaced))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(Color(.secondarySystemBackground), in: .rect(cornerRadius: cornerRad.component))
                            .contextMenu {
                                Button(action: {
                                    UIPasteboard.general.string = path
                                }) {
                                    Label("Copy Path", systemImage: "doc.on.doc")
                                }
                            }
                    }
                    .listRowSeparator(.hidden)
                    .listRowInsets(.sectionInsets)
                }
            }
            .listStyle(.plain)
            .navigationTitle("Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "xmark")
                }
            }
        }
    }
}

#Preview {
    TweakInfoView(tweak: ZeroTweak(name: "Hide Dock Background", icon: "dock.rectangle", minSupportedVersion: 16.0, maxSupportedVersion: 18.9, paths: ["/System/Library/PrivateFrameworks/CoreMaterial.framework/dockDark.materialrecipe", "/System/Library/PrivateFrameworks/CoreMaterial.framework/dockLight.materialrecipe"]))
}
