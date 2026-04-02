//
//  HomeView.swift
//  AudioReverse
//
//  Created by Furkan Hanci on 3/30/26.
//

import SwiftUI

struct HomeView: View {
    @State private var recorder = AudioRecorder()
    @State private var normalPlayer = AudioPlayer()
    @State private var reversedPlayer = AudioPlayer()

    @State private var reversedURL: URL?
    @State private var isReversing = false

    private var hasRecording: Bool {
        !recorder.isRecording && recorder.recordingURL != nil
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                recordCard
                playCard
                reverseCard
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black.ignoresSafeArea())
            .sensoryFeedback(.impact, trigger: recorder.isRecording)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        //TODO: Present DocumentPicker
                    } label: {
                        Image(systemName: "document")
                    }

                }
            }
        }
    }

    // MARK: - Record Card

    private var recordCard: some View {
        Button {
            if recorder.isRecording {
                recorder.stopRecording()
                reversedURL = nil
                reverseAudio()
            } else {
                normalPlayer.stop()
                reversedPlayer.stop()
                reversedURL = nil
                Task { await recorder.startRecording() }
            }
        } label: {
            cardContent(
                icon: recorder.isRecording ? "stop.fill" : "mic.fill",
                title: recorder.isRecording ? "Stop Recording" : "Start Recording",
                color: .red,
                isActive: recorder.isRecording,
                isDisabled: false
            )
        }
        .compatibleGlassEffect(cornerRadius: 24, interactiveEnabled: true)
    }

    // MARK: - Play Recorded Card

    private var playCard: some View {
        Button {
            if normalPlayer.isPlaying {
                normalPlayer.stop()
            } else if let url = recorder.recordingURL {
                reversedPlayer.stop()
                normalPlayer.play(url: url)
            }
        } label: {
            cardContent(
                icon: normalPlayer.isPlaying ? "stop.fill" : "play.fill",
                title: normalPlayer.isPlaying ? "Stop" : "Play Recorded",
                color: .green,
                isActive: normalPlayer.isPlaying,
                isDisabled: !hasRecording
            )
        }
        .disabled(!hasRecording)
        .sensoryFeedback(.success, trigger: normalPlayer.isPlaying)
        .compatibleGlassEffect(cornerRadius: 24, interactiveEnabled: hasRecording)
    }

    // MARK: - Play Reversed Card

    private var reverseCard: some View {
        Button {
            if reversedPlayer.isPlaying {
                reversedPlayer.stop()
            } else if let url = reversedURL {
                normalPlayer.stop()
                reversedPlayer.play(url: url)
            }
        } label: {
            cardContent(
                icon: reversedPlayer.isPlaying ? "stop.fill" : "arrow.counterclockwise",
                title: reversedPlayer.isPlaying ? "Stop" : "Play Reversed",
                color: .blue,
                isActive: reversedPlayer.isPlaying,
                isDisabled: reversedURL == nil
            )
        }
        .disabled(reversedURL == nil)
        .sensoryFeedback(.success, trigger: reversedPlayer.isPlaying)
        .compatibleGlassEffect(cornerRadius: 24, interactiveEnabled: reversedURL != nil)
    }

    // MARK: - Card Content

    private func cardContent(
        icon: String,
        title: String,
        color: Color,
        isActive: Bool,
        isDisabled: Bool
    ) -> some View {
        VStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 44, weight: .medium))
                .foregroundStyle(.white)
                .symbolEffect(.bounce, value: isActive)

            Text(title)
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(.white)

            if isActive {
                recordingIndicator(color: color)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(
                    LinearGradient(
                        colors: [
                            color.opacity(isDisabled ? 0.2 : 0.7),
                            color.opacity(isDisabled ? 0.1 : 0.4)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .strokeBorder(.white.opacity(isDisabled ? 0.05 : 0.15), lineWidth: 1)
        )
        .opacity(isDisabled ? 0.5 : 1)
        .animation(.easeInOut(duration: 0.3), value: isDisabled)
        .animation(.easeInOut(duration: 0.3), value: isActive)
    }

    private func recordingIndicator(color: Color) -> some View {
        HStack(spacing: 6) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
                .shadow(color: color, radius: 4)

            Text(String(format: "%.1fs", recorder.currentTime))
                .font(.system(size: 14, weight: .medium, design: .monospaced))
                .foregroundStyle(.white.opacity(0.8))
        }
        .transition(.scale.combined(with: .opacity))
    }

    // MARK: - Reverse Logic

    private func reverseAudio() {
        guard let url = recorder.recordingURL else { return }
        isReversing = true
        Task {
            do {
                reversedURL = try await AudioReverser.reverse(url: url)
            } catch {
                reversedURL = nil
            }
            isReversing = false
        }
    }
}

#Preview {
    HomeView()
}
