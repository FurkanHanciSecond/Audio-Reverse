//
//  OnboardingManager.swift
//  AudioReverse
//
//  Created by Furkan Hanci on 3/30/26.
//

import SwiftUI
import Observation

@MainActor @Observable
class OnboardingManager {

    var currentScreenIndex = 0

    var isOnboardingShown: Bool {
        get { UserDefaults.standard.bool(forKey: "isOnboardComplete") }
        set { UserDefaults.standard.set(newValue, forKey: "isOnboardComplete") }
    }

    func nextScreen() {
        if currentScreenIndex < 3 {
            currentScreenIndex += 1
        }
    }

    func completeOnboarding() {
        isOnboardingShown = true
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            UIView.transition(with: window, duration: 0.5, options: .transitionCrossDissolve, animations: {
                window.rootViewController = UIHostingController(rootView: MainTabView())
            }, completion: nil)
        }
    }
}
