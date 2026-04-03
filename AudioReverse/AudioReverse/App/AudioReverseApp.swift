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
    @State var onboardingManager = OnboardingManager()

    init() {
        Purchases.logLevel = .debug
        Purchases.configure(with: Configuration.Builder(withAPIKey: "appl_PaWIihPPutCwBxcLnZmMXauWhdt").with(storeKitVersion: .storeKit2).build())
    }

    var body: some Scene {
        WindowGroup {
            if onboardingManager.isOnboardingShown {
                MainTabView()
            } else {
                OnboardingView()
                    .environment(onboardingManager)
            }
        }
        .modelContainer(for: AudioHistoryItem.self)
    }
}
