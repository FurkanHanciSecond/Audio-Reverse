//
//  AudioReverseApp.swift
//  AudioReverse
//
//  Created by Furkan Hanci on 3/30/26.
//

import SwiftUI
import SwiftData
import RevenueCat

@main
struct AudioReverseApp: App {
    @State private var onboardingManager = OnboardingManager()
    @State private var userDefaultsManager = UserDefaultsManager()

    init() {
        Purchases.logLevel = .debug
        Purchases.configure(with: Configuration.Builder(withAPIKey: "appl_PaWIihPPutCwBxcLnZmMXauWhdt").with(storeKitVersion: .storeKit2).build())
        userDefaultsManager.setupDefaultsIfNeeded()
    }

    var body: some Scene {
        WindowGroup {
            if onboardingManager.isOnboardingShown {
                MainTabView()
                    .environment(userDefaultsManager)
            } else {
                OnboardingView()
                    .environment(onboardingManager)
                    .environment(userDefaultsManager)
            }
        }
        .modelContainer(for: AudioHistoryItem.self)
    }
}
