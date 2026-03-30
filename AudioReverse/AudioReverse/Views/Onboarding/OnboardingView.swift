//
//  OnboardingView.swift
//  AudioReverse
//
//  Created by Furkan Hanci on 3/30/26.
//

import SwiftUI

struct OnboardingView: View {
    @Environment(OnboardingManager.self) var onboardingManager

    var body: some View {
        ZStack {
            switch onboardingManager.currentScreenIndex {
            case 0:
                Onboard1()
                    .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))

            case 1:
                Onboard2()
                    .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))

            case 2:
                OnboardDemoView()
                    .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))

            case 3:
                OnboardPaywall()
                    .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))

            default:
                EmptyView()
            }
        }
        .animation(.easeInOut, value: onboardingManager.currentScreenIndex)
    }
}

#Preview {
    OnboardingView()
        .environment(OnboardingManager())
}
