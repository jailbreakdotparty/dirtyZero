//
//  ContentView.swift
//  dirtyZero
//
//  Created by Skadz on 5/8/25.
//

import SwiftUI
import DeviceKit
import notify

struct ContentView: View {
    let device = Device.current
    
    var body: some View {
        NavigationStack {
            VStack {
                List {
                    Section(header: Text("Tweaks"), content: {
                        Button("Hide dock", action: {
                            dirtyZeroHide(path: "/System/Library/PrivateFrameworks/CoreMaterial.framework/dockDark.materialrecipe")
                            dirtyZeroHide(path: "/System/Library/PrivateFrameworks/CoreMaterial.framework/dockLight.materialrecipe")
                        })
                        Button("Hide home bar", action: {
                            dirtyZeroHide(path: "/System/Library/PrivateFrameworks/MaterialKit.framework/Assets.car")
                        })
                        Button("Hide SystemVersion.plist (May causes the screen to be black till a forced reboot has been done)", action: {
                            
                            dirtyZeroHide(path: "/System/Library/CoreServices/SystemVersion.plist")
                        })                        
                        Button("Custom path (dangerous!)", action: {
                            Alertinator.shared.prompt(title: "Enter custom path", placeholder: "/path/to/the/file/to/hide") { path in
                                if let isEmpty = path, !path!.isEmpty {
                                    dirtyZeroHide(path: path!)
                                } else {
                                    Alertinator.shared.alert(title: "Invalid path", body: "Enter an actual path to what you want to hide/zero.")
                                }
                            }
                        })
                    })
                    
                    Section(header: Text("Logs"), content: {
                        HStack {
                            Spacer()
                            ZStack {
                                LogView()
                                    .padding(0.25)
                                    .frame(width: 340, height: 340)
                            }
                            Spacer()
                        }
                        .onAppear(perform: {
                            print("[*] Welcome to dirtyZero!\n[*] Running on \(device.systemName!) \(device.systemVersion!), \(device.description)")
                        })
                    })
                    
                    Section(header: Text("Actions"), content: {
                        Button("Attempt respring", action: {
                            // i don't think this'll work but i'm adding this from my phone so clearly i got bigger problems
                            notify_post("com.apple.springboard.toggleLockScreen")
                        })
                    })
                }
                
                Text("Exploit discovered by Ian Beer of Google Project Zero.\nMade by Skadz.\nSpecial thanks to the jailbreak.party team.")
                    .multilineTextAlignment(.center)
                    .font(.subheadline)
            }
            .navigationTitle("dirtyZero")
        }
    }
    
    func dirtyZeroHide(path: String) {
        let args = ["permasign", path]
        var argv = args.map { strdup($0) }
        
        _ = permasign(Int32(args.count), &argv)
    }
}

#Preview {
    ContentView()
}
