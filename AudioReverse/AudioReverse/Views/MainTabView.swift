//
//  MainTabView.swift
//  AudioReverse
//
//  Created by Furkan Hanci on 3/30/26.
//

import SwiftUI

enum AppTab {
    case home, settings
}

struct MainTabView: View {
    @State private var selection: AppTab = .home

    var body: some View {
        TabView(selection: $selection) {
            Tab("Home", systemImage: "house", value: .home) {
                HomeView()
            }

            Tab("Settings", systemImage: "gear", value: .settings) {
                SettingsView()
            }
        }
        .sensoryFeedback(.impact(flexibility: .solid, intensity: 0.5), trigger: selection)
        .tint(.white)
    }
}
