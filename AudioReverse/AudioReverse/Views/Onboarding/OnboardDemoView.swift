//
//  OnboardDemoView.swift
//  AudioReverse
//
//  Created by Furkan Hanci on 3/30/26.
//

import SwiftUI

struct OnboardDemoView: View {
    @Environment(OnboardingManager.self) var onboardManager
    @State private var recorder = AudioRecorder()
    @State private var player = AudioPlayer()

    @State private var displayedText = ""
    @State private var currentCharacterIndex = 0
    @State private var textAnimationComplete = false
    @State private var reversedURL: URL?
    @State private var isReversing = false
    @State private var showSuccessOverlay = false

    private let demoText = String(localized: "Try it yourself!")
    private let animationDelay: Duration = .milliseconds(50)

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 40) {
                Text(displayedText)
                    .font(.system(size: 45, weight: .semibold))
                    .multilineTextAlignment(.center)

                if textAnimationComplete {
                    recordButton

                    if !recorder.isRecording, recorder.recordingURL != nil, reversedURL == nil {
                        reverseButton
                    }

                    if let reversedURL {
                        playButton(url: reversedURL)
                    }
                }
            }
            .padding(.horizontal, 20)

            if showSuccessOverlay {
                successOverlay
            }
        }
        .sensoryFeedback(.impact(flexibility: .solid, intensity: 1), trigger: currentCharacterIndex)
        .onChange(of: player.isPlaying) { oldValue, newValue in
            if oldValue, !newValue, reversedURL != nil {
                Task {
                    try? await Task.sleep(for: .seconds(1))
                    withAnimation {
                        showSuccessOverlay = true
                    }
                    try? await Task.sleep(for: .seconds(1.5))
                    onboardManager.nextScreen()
                }
            }
        }
        .task {
            await startTypingAnimation()
        }
    }

    private var recordButton: some View {
        Button {
            if recorder.isRecording {
                recorder.stopRecording()
                reversedURL = nil
            } else {
                Task { await recorder.startRecording() }
            }
        } label: {
            ZStack {
                Circle()
                    .fill(recorder.isRecording ? .red : .white.opacity(0.15))
                    .frame(width: 80, height: 80)

                Image(systemName: recorder.isRecording ? "stop.fill" : "mic.fill")
                    .font(.system(size: 30))
                    .foregroundStyle(.white)
            }
            .compatibleCircularGlassEffect(interactiveEnabled: true)
        }
        .sensoryFeedback(.impact, trigger: recorder.isRecording)
    }

    private var reverseButton: some View {
        Button {
            guard let url = recorder.recordingURL else { return }
            isReversing = true
            Task {
                do {
                    let url = try await AudioReverser.reverse(url: url)
                    reversedURL = url
                    player.play(url: url)
                } catch {
                    reversedURL = nil
                }
                isReversing = false
            }
        } label: {
            Text("Reverse")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(.white)
                .padding(.horizontal, 40)
                .padding(.vertical, 14)
                .background(.white.opacity(0.15), in: .capsule)
        }
        .disabled(isReversing)
        .transition(.scale.combined(with: .opacity))
        .compatibleGlassEffectCapsule(cornerRadius: 15, interactiveEnabled: true)
    }

    private func playButton(url: URL) -> some View {
        Button {
            if player.isPlaying {
                player.stop()
            } else {
                player.play(url: url)
            }
        } label: {
            Label(
                player.isPlaying ? "Stop" : "Play Reversed",
                systemImage: player.isPlaying ? "stop.circle.fill" : "play.circle.fill"
            )
            .font(.system(size: 20, weight: .semibold))
            .foregroundStyle(.white)
            .padding(.horizontal, 30)
            .padding(.vertical, 14)
            .background(.white.opacity(0.15), in: .capsule)
        }
        .sensoryFeedback(.success, trigger: player.isPlaying)
        .transition(.scale.combined(with: .opacity))
    }

    private var successOverlay: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(.green)
                    .symbolEffect(.bounce, value: showSuccessOverlay)

                Text("Perfect!")
                    .font(.system(size: 42, weight: .bold))
            }
        }
        .transition(.opacity)
    }

    private func startTypingAnimation() async {
        for character in demoText {
            displayedText.append(character)
            currentCharacterIndex += 1
            try? await Task.sleep(for: animationDelay)
        }
        try? await Task.sleep(for: .milliseconds(300))
        withAnimation {
            textAnimationComplete = true
        }
    }
}

#Preview {
    OnboardDemoView()
        .environment(OnboardingManager())
}
