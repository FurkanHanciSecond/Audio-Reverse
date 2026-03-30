//
//  Onboard2.swift
//  AudioReverse
//
//  Created by Furkan Hanci on 3/30/26.
//

import SwiftUI

struct Onboard2: View {
    @Environment(OnboardingManager.self) var onboardManager
    @State private var isIconAnimated = false
    @State private var displayedText = ""
    @State private var currentCharacterIndex = 0

    private let reverseText = "Reverse"
    private let animationDelay: Duration = .milliseconds(50)

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 15) {
                Text("⏮️")
                    .font(.system(size: 125))
                    .scaleEffect(isIconAnimated ? 1 : 0.3)
                    .opacity(isIconAnimated ? 1 : 0)
                    .animation(.easeIn(duration: 0.6), value: isIconAnimated)

                Text(displayedText)
                    .font(.system(size: 80, weight: .bold))
            }
        }
        .sensoryFeedback(.impact, trigger: isIconAnimated)
        .sensoryFeedback(.impact(flexibility: .solid, intensity: 1), trigger: currentCharacterIndex)
        .task {
            isIconAnimated = true
            try? await Task.sleep(for: .milliseconds(1200))
            await startTypingAnimation()
            try? await Task.sleep(for: .seconds(1))
            onboardManager.nextScreen()
        }
    }

    private func startTypingAnimation() async {
        for character in reverseText {
            displayedText.append(character)
            currentCharacterIndex += 1
            try? await Task.sleep(for: animationDelay)
        }
    }
}

#Preview {
    Onboard2()
        .environment(OnboardingManager())
}
