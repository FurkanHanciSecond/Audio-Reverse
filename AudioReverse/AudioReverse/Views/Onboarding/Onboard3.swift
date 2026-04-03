//
//  Onboard3.swift
//  AudioReverse
//
//  Created by Furkan Hanci on 4/3/26.
//

import SwiftUI

struct Onboard3: View {
    @Environment(OnboardingManager.self) var onboardManager

    @State private var wordOpacity: Double = 0
    @State private var wordScale: Double = 0.5
    @State private var wordBlur: Double = 10

    private let fadeInDuration: Duration = .milliseconds(200)
    private let displayDuration: Duration = .seconds(1)
    private let fadeOutDuration: Duration = .milliseconds(150)

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            Text("Excited?")
                .font(.system(size: 32, weight: .bold))
                .foregroundStyle(.white)
                .opacity(wordOpacity)
                .scaleEffect(wordScale)
                .blur(radius: wordBlur)
        }
        .sensoryFeedback(.impact(flexibility: .soft), trigger: wordOpacity)
        .task {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                wordOpacity = 1
                wordScale = 1.0
                wordBlur = 0
            }

            try? await Task.sleep(for: fadeInDuration + displayDuration)

            withAnimation(.easeIn(duration: 0.15)) {
                wordOpacity = 0
                wordScale = 1.2
                wordBlur = 5
            }

            try? await Task.sleep(for: fadeOutDuration + .seconds(1))
            onboardManager.nextScreen()
        }
    }
}

#Preview {
    Onboard3()
        .environment(OnboardingManager())
}
