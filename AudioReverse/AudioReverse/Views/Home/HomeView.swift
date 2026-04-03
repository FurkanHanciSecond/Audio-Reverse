//
//  HomeView.swift
//  AudioReverse
//
//  Created by Furkan Hanci on 3/30/26.
//

import SwiftUI
import UniformTypeIdentifiers
import RevenueCat
import PhotosUI

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(UserDefaultsManager.self) private var userDefaultsManager
    @State private var viewModel = HomeViewModel()
    @State private var selectedVideoItem: PhotosPickerItem?

    private static let supportedAudioTypes: [UTType] = [
        .wav,
        .mp3,
        .mpeg4Audio,
        .aiff,
        .audio
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                VStack(spacing: 20) {
                    recordCard
                    playCard
                    reverseCard
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)

                if viewModel.isReversing {
                    reversingOverlay
                }

                if viewModel.isExtracting {
                    extractingOverlay
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black.ignoresSafeArea())
            .sensoryFeedback(.impact, trigger: viewModel.recorder.isRecording)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("", systemImage: "document.fill") {
                        viewModel.showFilePicker = true
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    PhotosPicker(selection: $selectedVideoItem, matching: .videos) {
                        Image(systemName: "video")
                    }
                }
            }
            .fileImporter(
                isPresented: $viewModel.showFilePicker,
                allowedContentTypes: Self.supportedAudioTypes,
                allowsMultipleSelection: false
            ) { result in
                viewModel.handleImportedFile(result)
            }
            .onChange(of: selectedVideoItem) {
                guard let selectedVideoItem else { return }
                viewModel.handleVideoSelected(selectedVideoItem)
                self.selectedVideoItem = nil
            }
            .alert("Error", isPresented: $viewModel.showError) {
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
            .onAppear {
                viewModel.modelContext = modelContext
                viewModel.userDefaultsManager = userDefaultsManager
                viewModel.check()
            }
            .fullScreenCover(isPresented: $viewModel.showPaywall) {
                PaywallView()
            }
        }
    }

    // MARK: - Record Card

    private var recordCard: some View {
        Button(action: viewModel.handleRecordTapped) {
            cardContent(
                icon: viewModel.recorder.isRecording ? "stop.fill" : "mic.fill",
                title: viewModel.recorder.isRecording ? "Stop Recording" : "Start Recording",
                color: .red,
                isActive: viewModel.recorder.isRecording,
                isDisabled: false,
                currentTime: viewModel.recorder.currentTime
            )
        }
        .compatibleGlassEffect(cornerRadius: 24, interactiveEnabled: true)
    }

    // MARK: - Play Recorded Card

    private var playCard: some View {
        Button(action: viewModel.handlePlayTapped) {
            cardContent(
                icon: viewModel.normalPlayer.isPlaying ? "stop.fill" : "play.fill",
                title: viewModel.normalPlayer.isPlaying ? "Stop" : "Play Recorded",
                color: .green,
                isActive: viewModel.normalPlayer.isPlaying,
                isDisabled: !viewModel.hasRecording,
                currentTime: viewModel.normalPlayer.remainingTime
            )
        }
        .disabled(!viewModel.hasRecording)
        .sensoryFeedback(.success, trigger: viewModel.normalPlayer.isPlaying)
        .compatibleGlassEffect(cornerRadius: 24, interactiveEnabled: viewModel.hasRecording)
    }

    // MARK: - Play Reversed Card

    private var reverseCard: some View {
        Button(action: viewModel.handleReversedPlayTapped) {
            cardContent(
                icon: viewModel.reversedPlayer.isPlaying ? "stop.fill" : "arrow.counterclockwise",
                title: viewModel.reversedPlayer.isPlaying ? "Stop" : "Play Reversed",
                color: .blue,
                isActive: viewModel.reversedPlayer.isPlaying,
                isDisabled: viewModel.reversedURL == nil,
                currentTime: viewModel.reversedPlayer.remainingTime
            )
        }
        .disabled(viewModel.reversedURL == nil)
        .sensoryFeedback(.success, trigger: viewModel.reversedPlayer.isPlaying)
        .compatibleGlassEffect(cornerRadius: 24, interactiveEnabled: viewModel.reversedURL != nil)
    }

    // MARK: - Reversing Overlay

    private var reversingOverlay: some View {
        ZStack {
            Color.black.opacity(0.7)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                ProgressView()
                    .controlSize(.extraLarge)
                    .tint(.white)

                Text("Reversing Audio...")
                    .font(.headline)
                    .foregroundStyle(.white)
            }
        }
        .transition(.opacity)
    }

    // MARK: - Extracting Overlay

    private var extractingOverlay: some View {
        ZStack {
            Color.black.opacity(0.7)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                ProgressView()
                    .controlSize(.extraLarge)
                    .tint(.white)

                Text("Extracting Audio...")
                    .font(.headline)
                    .foregroundStyle(.white)
            }
        }
        .transition(.opacity)
    }

    // MARK: - Card Content

    private func cardContent(
        icon: String,
        title: String,
        color: Color,
        isActive: Bool,
        isDisabled: Bool,
        currentTime: TimeInterval = 0
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
                recordingIndicator(color: color, currentTime: currentTime)
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

    private func recordingIndicator(color: Color, currentTime: TimeInterval) -> some View {
        HStack(spacing: 6) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
                .shadow(color: color, radius: 4)

            HStack(spacing: 0) {
                Text(currentTime, format: .number.precision(.fractionLength(1)))
                Text("s")
            }
            .font(.system(size: 14, weight: .medium, design: .monospaced))
            .foregroundStyle(.white.opacity(0.8))
        }
        .transition(.scale.combined(with: .opacity))
    }
}

#Preview {
    HomeView()
}
