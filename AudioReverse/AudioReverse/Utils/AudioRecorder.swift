//
//  AudioRecorder.swift
//  AudioReverse
//
//  Created by Furkan Hanci on 3/30/26.
//

import AVFoundation
import Observation

@MainActor @Observable
class AudioRecorder {

    private(set) var isRecording = false
    private(set) var recordingURL: URL?
    private(set) var currentTime: TimeInterval = 0
    private(set) var error: AudioRecorderError?

    private var audioRecorder: AVAudioRecorder?
    private var timer: Timer?

    private var recordingsDirectory: URL {
        URL.documentsDirectory.appending(path: "Recordings\(UUID().uuidString)")
    }

    private var recordingSettings: [String: Any] {
        [
            AVFormatIDKey: Int(kAudioFormatLinearPCM),
            AVSampleRateKey: 44100.0,
            AVNumberOfChannelsKey: 2,
            AVLinearPCMBitDepthKey: 16,
            AVLinearPCMIsFloatKey: false,
            AVLinearPCMIsBigEndianKey: false
        ]
    }

    func startRecording() async {
        guard !isRecording else { return }

        let permitted = await requestPermission()
        guard permitted else {
            error = .permissionDenied
            return
        }

        configureSession()
        createRecordingsDirectoryIfNeeded()

        let fileName = "recording_\(Date.now.timeIntervalSince1970).wav"
        let url = recordingsDirectory.appending(path: fileName)

        do {
            audioRecorder = try AVAudioRecorder(url: url, settings: recordingSettings)
            audioRecorder?.record()
            recordingURL = url
            isRecording = true
            currentTime = 0
            error = nil
            startTimer()
        } catch {
            self.error = .recordingFailed(error.localizedDescription)
        }
    }

    func stopRecording() {
        guard isRecording else { return }
        audioRecorder?.stop()
        audioRecorder = nil
        isRecording = false
        stopTimer()
    }

    func deleteRecording(at url: URL) {
        try? FileManager.default.removeItem(at: url)
        if recordingURL == url {
            recordingURL = nil
        }
    }

    private func requestPermission() async -> Bool {
        await withCheckedContinuation { continuation in
            AVAudioApplication.requestRecordPermission { granted in
                continuation.resume(returning: granted)
            }
        }
    }

    private func configureSession() {
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
        try? session.setActive(true)
    }

    private func createRecordingsDirectoryIfNeeded() {
        if !FileManager.default.fileExists(atPath: recordingsDirectory.path()) {
            try? FileManager.default.createDirectory(at: recordingsDirectory, withIntermediateDirectories: true)
        }
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self else { return }
                guard let recorder = self.audioRecorder, recorder.isRecording else { return }
                self.currentTime = recorder.currentTime
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}

enum AudioRecorderError: Equatable {
    case permissionDenied
    case recordingFailed(String)

    var message: String {
        switch self {
        case .permissionDenied:
            "Microphone access is required to record audio. Please enable it in Settings."
        case .recordingFailed(let detail):
            "Recording failed: \(detail)"
        }
    }
}
