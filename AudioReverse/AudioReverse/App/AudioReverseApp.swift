//
//  AudioReverseApp.swift
//  AudioReverse
//
//  Created by Furkan Hanci on 3/30/26.
//

import SwiftUI

@main
struct AudioReverseApp: App {
    @StateObject var onboardingManager = OnboardingManager()

    var body: some Scene {
        WindowGroup {
            if onboardingManager.isOnboardingShown {
                MainTabView()
            } else {
                OnboardingView()
                    .environmentObject(onboardingManager)
            }
        }
    }
}
