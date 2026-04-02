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

    var isLooping = false

    var rate: Float = 1.0 {
        didSet { timePitch.rate = rate }
    }

    /// Pitch offset in cents (100 cents = 1 semitone).
    var pitch: Float = 0 {
        didSet { timePitch.pitch = pitch }
    }

    var remainingTime: TimeInterval {
        max(duration - currentTime, 0)
    }

    private let engine = AVAudioEngine()
    private let playerNode = AVAudioPlayerNode()
    private let timePitch = AVAudioUnitTimePitch()
    private var audioFile: AVAudioFile?
    private var timer: Timer?
    private var seekFrame: AVAudioFramePosition = 0

    init() {
        engine.attach(playerNode)
        engine.attach(timePitch)
        engine.connect(playerNode, to: timePitch, format: nil)
        engine.connect(timePitch, to: engine.mainMixerNode, format: nil)
    }

    func play(url: URL) {
        stop()

        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default)
            try session.setActive(true)

            audioFile = try AVAudioFile(forReading: url)
            guard let file = audioFile else { return }

            duration = Double(file.length) / file.processingFormat.sampleRate

            timePitch.rate = rate
            timePitch.pitch = pitch

            try engine.start()

            schedulePlayback(from: 0)
            playerNode.play()

            isPlaying = true
            seekFrame = 0
            startTimer()
        } catch {
            isPlaying = false
        }
    }

    func stop() {
        stopTimer()
        playerNode.stop()
        if engine.isRunning { engine.stop() }
        audioFile = nil
        isPlaying = false
        currentTime = 0
        seekFrame = 0
    }

    func seek(to time: TimeInterval) {
        guard let file = audioFile else { return }
        let clamped = max(0, min(time, duration))
        let targetFrame = AVAudioFramePosition(clamped * file.processingFormat.sampleRate)

        playerNode.stop()
        schedulePlayback(from: targetFrame)
        playerNode.play()

        seekFrame = targetFrame
        currentTime = clamped
    }

    // MARK: - Private

    private func schedulePlayback(from startFrame: AVAudioFramePosition) {
        guard let file = audioFile else { return }
        let remaining = AVAudioFrameCount(file.length - startFrame)
        guard remaining > 0 else { return }

        playerNode.scheduleSegment(
            file,
            startingFrame: startFrame,
            frameCount: remaining,
            at: nil
        ) { [weak self] in
            Task { @MainActor [weak self] in
                guard let self else { return }
                if self.isLooping && self.isPlaying {
                    self.seekFrame = 0
                    self.schedulePlayback(from: 0)
                } else {
                    self.stopTimer()
                    self.isPlaying = false
                    self.currentTime = 0
                    self.seekFrame = 0
                }
            }
        }
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self,
                      let nodeTime = self.playerNode.lastRenderTime,
                      let playerTime = self.playerNode.playerTime(forNodeTime: nodeTime),
                      let file = self.audioFile else { return }
                let frame = playerTime.sampleTime + self.seekFrame
                self.currentTime = Double(frame) / file.processingFormat.sampleRate
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}
