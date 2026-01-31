//
//  MainView.swift
//  dirtyZero
//
//  Created by Main on 1/21/26.
//

import SwiftUI

struct MainView: View {
    var body: some View {
        if UIDevice.current.userInterfaceIdiom == .pad {
            NavigationSplitView {
                ContentView()
                    .navigationSplitViewColumnWidth(385)
            } detail: {
                ListedTweaksView()
                    .navigationTitle("Tweaks")
                    .navigationBarTitleDisplayMode(.inline)
            }
        } else {
            ContentView()
        }
    }
}

#Preview {
    MainView()
}
