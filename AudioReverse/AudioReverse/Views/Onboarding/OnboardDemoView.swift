//
//  OnboardDemoView.swift
//  AudioReverse
//
//  Created by Furkan Hanci on 3/30/26.
//

import SwiftUI

struct OnboardDemoView: View {
    @Environment(OnboardingManager.self) var onboardManager

    var body: some View {
        ZStack {
            Color.green.ignoresSafeArea()

            Button("Onboard Demo") {
                onboardManager.nextScreen()
            }
        }
    }
}

#Preview {
    OnboardDemoView()
        .environment(OnboardingManager())
}
