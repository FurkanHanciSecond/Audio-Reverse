//
//  AudioReverseApp.swift
//  AudioReverse
//
//  Created by Furkan Hanci on 3/30/26.
//

import SwiftUI

@main
struct AudioReverseApp: App {
    @State var onboardingManager = OnboardingManager()

    var body: some Scene {
        WindowGroup {
            OnboardingView()
                .environment(onboardingManager)
//            if onboardingManager.isOnboardingShown {
//                MainTabView()
//            } else {
//                OnboardingView()
//                    .environment(onboardingManager)
//            }
        }
    }
}
