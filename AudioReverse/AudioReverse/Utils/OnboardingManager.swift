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
        get {
            access(keyPath: \.isOnboardingShown)
            return UserDefaults.standard.bool(forKey: "isOnboardComplete")
        }
        set {
            withMutation(keyPath: \.isOnboardingShown) {
                UserDefaults.standard.set(newValue, forKey: "isOnboardComplete")
            }
        }
    }

    func nextScreen() {
        if currentScreenIndex < 4 {
            currentScreenIndex += 1
        }
    }

    func completeOnboarding() {
        withAnimation(.easeInOut(duration: 0.5)) {
            isOnboardingShown = true
        }
    }
}
