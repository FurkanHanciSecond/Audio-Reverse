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

    private var audioPlayer: AVAudioPlayer?
    private var delegate: PlayerDelegate?

    func play(url: URL) {
        stop()

        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default)
            try session.setActive(true)

            audioPlayer = try AVAudioPlayer(contentsOf: url)
            delegate = PlayerDelegate { [weak self] in
                Task { @MainActor in
                    self?.isPlaying = false
                }
            }
            audioPlayer?.delegate = delegate
            audioPlayer?.play()
            isPlaying = true
        } catch {
            isPlaying = false
        }
    }

    func stop() {
        audioPlayer?.stop()
        audioPlayer = nil
        delegate = nil
        isPlaying = false
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
