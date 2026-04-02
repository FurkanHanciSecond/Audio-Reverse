//
//  AudioPlayer.swift
//  AudioReverse
//
//  Created by Furkan Hanci on 3/30/26.
//

import AVFoundation
import Observation

@MainActor @Observable
class AudioPlayer {

    private(set) var isPlaying = false
    private(set) var currentTime: TimeInterval = 0
    private(set) var duration: TimeInterval = 0

    var isLooping = false {
        didSet { audioPlayer?.numberOfLoops = isLooping ? -1 : 0 }
    }

    var rate: Float = 1.0 {
        didSet { audioPlayer?.rate = rate }
    }

    var remainingTime: TimeInterval {
        max(duration - currentTime, 0)
    }

    private var audioPlayer: AVAudioPlayer?
    private var delegate: PlayerDelegate?
    private var timer: Timer?

    func play(url: URL) {
        stop()

        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default)
            try session.setActive(true)

            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.enableRate = true
            audioPlayer?.rate = rate
            audioPlayer?.numberOfLoops = isLooping ? -1 : 0
            delegate = PlayerDelegate { [weak self] in
                Task { @MainActor in
                    self?.stopTimer()
                    self?.isPlaying = false
                    self?.currentTime = 0
                }
            }
            audioPlayer?.delegate = delegate
            audioPlayer?.play()
            duration = audioPlayer?.duration ?? 0
            isPlaying = true
            startTimer()
        } catch {
            isPlaying = false
        }
    }

    func stop() {
        stopTimer()
        audioPlayer?.stop()
        audioPlayer = nil
        delegate = nil
        isPlaying = false
        currentTime = 0
    }

    func seek(to time: TimeInterval) {
        let clamped = max(0, min(time, duration))
        audioPlayer?.currentTime = clamped
        currentTime = clamped
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.currentTime = self?.audioPlayer?.currentTime ?? 0
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}

private class PlayerDelegate: NSObject, AVAudioPlayerDelegate {
    let onFinish: () -> Void

    init(onFinish: @escaping () -> Void) {
        self.onFinish = onFinish
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        onFinish()
    }
}
