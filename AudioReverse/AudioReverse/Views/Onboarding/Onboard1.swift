//
//  Onboard1.swift
//  AudioReverse
//
//  Created by Furkan Hanci on 3/30/26.
//

import SwiftUI

struct Onboard1: View {
    @Environment(OnboardingManager.self) var onboardManager
    @State private var isMicAnimated = false
    @State private var displayedText = ""
    @State private var currentCharacterIndex = 0

    private let recordText = "Record"
    private let animationDelay: Duration = .milliseconds(50)

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 15) {
                Text("🎙️")
                    .font(.system(size: 125))
                    .scaleEffect(isMicAnimated ? 1 : 0.3)
                    .opacity(isMicAnimated ? 1 : 0)
                    .animation(.easeIn(duration: 0.6), value: isMicAnimated)

                Text(displayedText)
                    .font(.system(size: 80, weight: .bold))
            }
        }
        .sensoryFeedback(.impact, trigger: isMicAnimated)
        .sensoryFeedback(.impact(flexibility: .solid, intensity: 1), trigger: currentCharacterIndex)
        .task {
            isMicAnimated = true
            try? await Task.sleep(for: .milliseconds(1200))
            await startTypingAnimation()
            try? await Task.sleep(for: .seconds(1))
            onboardManager.nextScreen()
        }
    }

    private func startTypingAnimation() async {
        for character in recordText {
            displayedText.append(character)
            currentCharacterIndex += 1
            try? await Task.sleep(for: animationDelay)
        }
    }
}

#Preview {
    Onboard1()
        .environment(OnboardingManager())
}
