//
//  OnboardPaywall.swift
//  AudioReverse
//
//  Created by Furkan Hanci on 3/30/26.
//

import SwiftUI

struct OnboardPaywall: View {

    @EnvironmentObject var onboardManager: OnboardingManager

    var body: some View {
        Text("Onboard Paywall")
            .onTapGesture {
                onboardManager.completeOnboarding()
            }
    }
}

#Preview {
    OnboardPaywall()
}
