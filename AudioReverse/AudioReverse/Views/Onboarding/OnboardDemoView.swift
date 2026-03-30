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
            Color.black.ignoresSafeArea()

            VStack {
                Text("Let's Take A Demo")
                    .font(.system(size: 32, weight: .semibold))
            }
        }
    }
}

#Preview {
    OnboardDemoView()
        .environment(OnboardingManager())
}
