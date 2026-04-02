//
//  OnboardPaywall.swift
//  AudioReverse
//
//  Created by Furkan Hanci on 3/30/26.
//

import SwiftUI

struct OnboardPaywall: View {

    @Environment(OnboardingManager.self) var onboardManager

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            Button("Onboard Paywall") {
                onboardManager.completeOnboarding()
            }
        }
    }
}

#Preview {
    OnboardPaywall()
        .environment(OnboardingManager())
}
