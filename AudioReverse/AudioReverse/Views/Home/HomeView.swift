//
//  HomeView.swift
//  AudioReverse
//
//  Created by Furkan Hanci on 3/30/26.
//

import SwiftUI
import SwiftData
import AVFoundation
import UniformTypeIdentifiers

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var recorder = AudioRecorder()
    @State private var normalPlayer = AudioPlayer()
    @State private var reversedPlayer = AudioPlayer()

    @State private var reversedURL: URL?
    @State private var isReversing = false
    @State private var showFilePicker = false
    @State private var importedFileURL: URL?
    @State private var errorMessage: String?

    private var hasRecording: Bool {
        !recorder.isRecording && (recorder.recordingURL != nil || importedFileURL != nil)
    }

    private var sourceURL: URL? {
        importedFileURL ?? recorder.recordingURL
    }

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

                if isReversing {
                    reversingOverlay
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black.ignoresSafeArea())
            .sensoryFeedback(.impact, trigger: recorder.isRecording)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Import Audio", systemImage: "document.fill") {
                        showFilePicker = true
                    }
                }
            }
            .fileImporter(
                isPresented: $showFilePicker,
                allowedContentTypes: Self.supportedAudioTypes,
                allowsMultipleSelection: false
            ) { result in
                handleImportedFile(result)
            }
            .alert("Error", isPresented: Binding(
                get: { errorMessage != nil },
                set: { if !$0 { errorMessage = nil } }
            )) {
                Button("OK") { errorMessage = nil }
            } message: {
                Text(errorMessage ?? "")
            }
        }
    }

    // MARK: - Record Card

    private var recordCard: some View {
        Button {
            handleRecordTapped()
        } label: {
            cardContent(
                icon: recorder.isRecording ? "stop.fill" : "mic.fill",
                title: recorder.isRecording ? "Stop Recording" : "Start Recording",
                color: .red,
                isActive: recorder.isRecording,
                isDisabled: false,
                currentTime: recorder.currentTime
            )
        }
        .compatibleGlassEffect(cornerRadius: 24, interactiveEnabled: true)
    }

    // MARK: - Play Recorded Card

    private var playCard: some View {
        Button {
            handlePlayTapped()
        } label: {
            cardContent(
                icon: normalPlayer.isPlaying ? "stop.fill" : "play.fill",
                title: normalPlayer.isPlaying ? "Stop" : "Play Recorded",
                color: .green,
                isActive: normalPlayer.isPlaying,
                isDisabled: !hasRecording,
                currentTime: normalPlayer.remainingTime
            )
        }
        .disabled(!hasRecording)
        .sensoryFeedback(.success, trigger: normalPlayer.isPlaying)
        .compatibleGlassEffect(cornerRadius: 24, interactiveEnabled: hasRecording)
    }

    // MARK: - Play Reversed Card

    private var reverseCard: some View {
        Button {
            handleReversedPlayTapped()
        } label: {
            cardContent(
                icon: reversedPlayer.isPlaying ? "stop.fill" : "arrow.counterclockwise",
                title: reversedPlayer.isPlaying ? "Stop" : "Play Reversed",
                color: .blue,
                isActive: reversedPlayer.isPlaying,
                isDisabled: reversedURL == nil,
                currentTime: reversedPlayer.remainingTime
            )
        }
        .disabled(reversedURL == nil)
        .sensoryFeedback(.success, trigger: reversedPlayer.isPlaying)
        .compatibleGlassEffect(cornerRadius: 24, interactiveEnabled: reversedURL != nil)
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

            Text(String(format: "%.1fs", currentTime))
                .font(.system(size: 14, weight: .medium, design: .monospaced))
                .foregroundStyle(.white.opacity(0.8))
        }
        .transition(.scale.combined(with: .opacity))
    }

    // MARK: - Actions

    private func handleRecordTapped() {
        if recorder.isRecording {
            recorder.stopRecording()
            importedFileURL = nil
            reversedURL = nil
            reverseAudio(from: recorder.recordingURL, sourceType: .recording)
        } else {
            normalPlayer.stop()
            reversedPlayer.stop()
            importedFileURL = nil
            reversedURL = nil
            Task { await recorder.startRecording() }
        }
    }

    private func handlePlayTapped() {
        if normalPlayer.isPlaying {
            normalPlayer.stop()
        } else if let url = sourceURL {
            reversedPlayer.stop()
            normalPlayer.play(url: url)
        }
    }

    private func handleReversedPlayTapped() {
        if reversedPlayer.isPlaying {
            reversedPlayer.stop()
        } else if let url = reversedURL {
            normalPlayer.stop()
            reversedPlayer.play(url: url)
        }
    }

    private func handleImportedFile(_ result: Result<[URL], Error>) {
        switch result {
        case .failure:
            return
        case .success(let urls):
            guard let selectedURL = urls.first else { return }
            importFile(from: selectedURL)
        }
    }

    private func importFile(from selectedURL: URL) {
        guard selectedURL.startAccessingSecurityScopedResource() else {
            errorMessage = "Could not access the selected file."
            return
        }
        defer { selectedURL.stopAccessingSecurityScopedResource() }

        let importDir = URL.documentsDirectory.appending(path: "Imported")
        let uniqueName = "\(UUID().uuidString)_\(selectedURL.lastPathComponent)"
        let destination = importDir.appending(path: uniqueName)

        do {
            if !FileManager.default.fileExists(atPath: importDir.path()) {
                try FileManager.default.createDirectory(at: importDir, withIntermediateDirectories: true)
            }
            try FileManager.default.copyItem(at: selectedURL, to: destination)
        } catch {
            errorMessage = "Failed to import file: \(error.localizedDescription)"
            return
        }

        normalPlayer.stop()
        reversedPlayer.stop()
        importedFileURL = nil
        reversedURL = nil

        importedFileURL = destination
        reverseAudio(from: destination, sourceType: .fileImport)
    }

    private func reverseAudio(from url: URL?, sourceType: AudioSourceType) {
        guard let url else { return }
        withAnimation {
            isReversing = true
        }
        Task {
            do {
                let reversed = try await AudioReverser.reverse(url: url)
                reversedURL = reversed
                saveHistoryItem(sourceURL: url, reversedURL: reversed, sourceType: sourceType)
            } catch {
                reversedURL = nil
                errorMessage = "Failed to reverse audio: \(error.localizedDescription)"
            }
            withAnimation {
                isReversing = false
            }
        }
    }

    private func saveHistoryItem(sourceURL: URL, reversedURL: URL, sourceType: AudioSourceType) {
        let name = sourceURL.deletingPathExtension().lastPathComponent
        let duration = audioDuration(for: sourceURL)

        let item = AudioHistoryItem(
            name: name,
            sourceType: sourceType,
            originalFilePath: sourceURL.path(),
            reversedFilePath: reversedURL.path(),
            duration: duration, itemURL: sourceURL
        )
        modelContext.insert(item)
        try? modelContext.save()
    }

    private func audioDuration(for url: URL) -> TimeInterval {
        do {
            let audioFile = try AVAudioFile(forReading: url)
            let frames = Double(audioFile.length)
            let sampleRate = audioFile.processingFormat.sampleRate
            return frames / sampleRate
        } catch {
            return 0
        }
    }
}

#Preview {
    HomeView()
}
