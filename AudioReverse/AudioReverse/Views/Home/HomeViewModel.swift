//
//  HomeViewModel.swift
//  AudioReverse
//
//  Created by Furkan Hanci on 4/3/26.
//

import Foundation
import AVFoundation
import SwiftData
import Photos
import PhotosUI
import RevenueCat
import StoreKit
import _PhotosUI_SwiftUI

@MainActor @Observable
final class HomeViewModel {

    var recorder = AudioRecorder()
    var normalPlayer = AudioPlayer()
    var reversedPlayer = AudioPlayer()

    var reversedURL: URL?
    var isReversing = false
    var showFilePicker = false
    var showPaywall = false
    var isExtracting = false
    var importedFileURL: URL?
    var errorMessage: String?
    var showError = false

    var modelContext: ModelContext?
    var userDefaultsManager: UserDefaultsManager?

    private let maxFreeDuration: TimeInterval = 60

    var hasRecording: Bool {
        !recorder.isRecording && (recorder.recordingURL != nil || importedFileURL != nil)
    }

    var sourceURL: URL? {
        importedFileURL ?? recorder.recordingURL
    }

    // MARK: - Actions

    func check() {
        userDefaultsManager?.appRunCount += 1
        checkSubscriptionStatus()
    }

    func checkSubscriptionStatus(triggerPaywallIfNeeded: Bool = true) {
        Task {
            guard let info = try? await Purchases.shared.customerInfo() else { return }
            let isActive = self.checkPremiumEntitlement(info: info)
            if isActive {
                self.handlePremiumActive(info: info)
            } else {
                self.handlePremiumInactive(info: info, triggerPaywallIfNeeded: triggerPaywallIfNeeded)
            }
        }
    }

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
            return
        }

        guard let userDefaultsManager else { return }
        guard let url = reversedURL else { return }

        if !userDefaultsManager.isPremium {
            let sourceToCheck = sourceURL ?? url
            if userDefaultsManager.remainingCount <= 0 || !canProcessAudio(url: sourceToCheck) {
                showPaywall = true
                return
            }
            userDefaultsManager.remainingCount -= 1
        }

        normalPlayer.stop()
        reversedPlayer.play(url: url)
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

    func handleVideoSelected(_ item: PhotosPickerItem) {
        isExtracting = true
        Task {
            defer { isExtracting = false }

            do {
                guard let videoData = try await item.loadTransferable(type: VideoTransferable.self) else {
                    errorMessage = "Could not load the selected video."
                    showError = true
                    return
                }

                let videoAsset = AVURLAsset(url: videoData.url)
                let extractedAudioURL = try await MediaProcessingService.extractAudio(from: videoAsset)

                normalPlayer.stop()
                reversedPlayer.stop()
                importedFileURL = extractedAudioURL
                reversedURL = nil

                reverseAudio(from: extractedAudioURL, sourceType: .fileImport)
            } catch {
                errorMessage = "Failed to extract audio: \(error.localizedDescription)"
                showError = true
            }
        }
    }

    // MARK: - File Import

    private func importFile(from selectedURL: URL) {
        guard selectedURL.startAccessingSecurityScopedResource() else {
            errorMessage = "Could not access the selected file."
            showError = true
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
            showError = true
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
                showError = true
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

    private func canProcessAudio(url: URL) -> Bool {
        guard let userDefaultsManager else { return true }
        if userDefaultsManager.isPremium { return true }
        return audioDuration(for: url) <= maxFreeDuration
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

//MARK: - RevenueCat
extension HomeViewModel {
    private func checkPremiumEntitlement(info: CustomerInfo) -> Bool {
        let premiumEntitlements = ["audioReverseLifeTime"]
        return premiumEntitlements.contains { info.entitlements[$0]?.isActive == true }
    }

    private func handlePremiumActive(info: CustomerInfo) {
        userDefaultsManager?.isPremium = true
    }

    private func handlePremiumInactive(info: CustomerInfo, triggerPaywallIfNeeded: Bool) {
        userDefaultsManager?.isPremium = false

        guard triggerPaywallIfNeeded else { return }

        let count = userDefaultsManager?.appRunCount ?? 0

        if count == 2 {
            Task { @MainActor in
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                    AppStore.requestReview(in: windowScene)
                }
            }
        } else if count >= 3 && count.isMultiple(of: 2) == false {
            presentNormalPaywallAndTrackEvent(info: info)
        }
    }

    private func presentNormalPaywallAndTrackEvent(info: CustomerInfo) {
        showPaywall = true
    }
}
