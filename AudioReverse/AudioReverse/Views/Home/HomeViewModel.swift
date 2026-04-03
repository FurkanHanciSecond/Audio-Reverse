//
//  HomeViewModel.swift
//  AudioReverse
//
//  Created by Furkan Hanci on 4/3/26.
//

import Foundation
import AVFoundation
import SwiftData

@MainActor @Observable
final class HomeViewModel {
    var recorder = AudioRecorder()
    var normalPlayer = AudioPlayer()
    var reversedPlayer = AudioPlayer()

    var reversedURL: URL?
    var isReversing = false
    var showFilePicker = false
    var importedFileURL: URL?
    var errorMessage: String?

    var modelContext: ModelContext?

    var hasRecording: Bool {
        !recorder.isRecording && (recorder.recordingURL != nil || importedFileURL != nil)
    }

    var sourceURL: URL? {
        importedFileURL ?? recorder.recordingURL
    }

    // MARK: - Actions

    func handleRecordTapped() {
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

    func handlePlayTapped() {
        if normalPlayer.isPlaying {
            normalPlayer.stop()
        } else if let url = sourceURL {
            reversedPlayer.stop()
            normalPlayer.play(url: url)
        }
    }

    func handleReversedPlayTapped() {
        if reversedPlayer.isPlaying {
            reversedPlayer.stop()
        } else if let url = reversedURL {
            normalPlayer.stop()
            reversedPlayer.play(url: url)
        }
    }

    func handleImportedFile(_ result: Result<[URL], Error>) {
        switch result {
        case .failure:
            return
        case .success(let urls):
            guard let selectedURL = urls.first else { return }
            importFile(from: selectedURL)
        }
    }

    // MARK: - File Import

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

    // MARK: - Audio Processing

    private func reverseAudio(from url: URL?, sourceType: AudioSourceType) {
        guard let url else { return }
        isReversing = true
        Task {
            do {
                let reversed = try await AudioReverser.reverse(url: url)
                reversedURL = reversed
                saveHistoryItem(sourceURL: url, reversedURL: reversed, sourceType: sourceType)
            } catch {
                reversedURL = nil
                errorMessage = "Failed to reverse audio: \(error.localizedDescription)"
            }
            isReversing = false
        }
    }

    // MARK: - Persistence

    private func saveHistoryItem(sourceURL: URL, reversedURL: URL, sourceType: AudioSourceType) {
        guard let modelContext else { return }
        let name = sourceURL.deletingPathExtension().lastPathComponent
        let duration = audioDuration(for: sourceURL)

        let item = AudioHistoryItem(
            name: name,
            sourceType: sourceType,
            originalFilePath: relativePath(from: sourceURL),
            reversedFilePath: relativePath(from: reversedURL),
            duration: duration
        )
        modelContext.insert(item)
        try? modelContext.save()
    }

    // MARK: - Helpers

    private func relativePath(from url: URL) -> String {
        let docsPath = URL.documentsDirectory.path(percentEncoded: false)
        let fullPath = url.path(percentEncoded: false)
        guard fullPath.hasPrefix(docsPath) else { return fullPath }
        var relative = String(fullPath.dropFirst(docsPath.count))
        if relative.hasPrefix("/") { relative = String(relative.dropFirst()) }
        return relative
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
