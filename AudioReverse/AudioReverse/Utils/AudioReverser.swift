//
//  AudioReverser.swift
//  AudioReverse
//
//  Created by Furkan Hanci on 3/30/26.
//

import AVFoundation

enum AudioReverserError: LocalizedError {
    case bufferCreationFailed
    case channelDataUnavailable

    var errorDescription: String? {
        switch self {
        case .bufferCreationFailed:
            "Failed to create audio buffer."
        case .channelDataUnavailable:
            "Audio channel data is unavailable."
        }
    }
}

enum AudioReverser {

    static func reverse(url: URL) async throws -> URL {
        let audioFile = try AVAudioFile(forReading: url)
        let format = audioFile.processingFormat
        let frameCount = AVAudioFrameCount(audioFile.length)

        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else {
            throw AudioReverserError.bufferCreationFailed
        }

        try audioFile.read(into: buffer)

        guard let reversedBuffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else {
            throw AudioReverserError.bufferCreationFailed
        }
        reversedBuffer.frameLength = frameCount

        let channelCount = Int(format.channelCount)

        for channel in 0..<channelCount {
            guard let source = buffer.floatChannelData?[channel],
                  let destination = reversedBuffer.floatChannelData?[channel] else {
                throw AudioReverserError.channelDataUnavailable
            }

            for frame in 0..<Int(frameCount) {
                destination[frame] = source[Int(frameCount) - 1 - frame]
            }
        }

        let reversedURL = url.deletingLastPathComponent()
            .appending(path: "reversed_\(url.lastPathComponent)")

        let outputFile = try AVAudioFile(
            forWriting: reversedURL,
            settings: format.settings
        )
        try outputFile.write(from: reversedBuffer)

        return reversedURL
    }
}
