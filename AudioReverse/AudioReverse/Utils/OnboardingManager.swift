//
//  OnboardingManager.swift
//  AudioReverse
//
//  Created by Furkan Hanci on 3/30/26.
//

import SwiftUI
import Combine

class OnboardingManager: ObservableObject {

    @Published var currentScreenIndex = 0
    @AppStorage("isOnboardComplete") var isOnboardingShown: Bool = false

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
