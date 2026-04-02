//
//  AudioHistoryItem.swift
//  AudioReverse
//
//  Created by Furkan Hanci on 4/2/26.
//

import Foundation
import SwiftData

enum AudioSourceType: String, Codable {
    case recording
    case fileImport
}

@Model
final class AudioHistoryItem {
    var name: String
    var sourceType: AudioSourceType
    /// Relative path from Documents directory (e.g. "Recordings/recording_xxx.wav").
    /// Legacy records may contain an absolute path starting with "/".
    var originalFilePath: String
    var reversedFilePath: String?
    var duration: TimeInterval
    var createdDate: Date
    // itemURL kept for schema compatibility; use originalURL instead.
    var itemURL: URL?

    /// Always-valid URL reconstructed from the stored path.
    var originalURL: URL {
        if originalFilePath.hasPrefix("/") {
            return URL(fileURLWithPath: originalFilePath)
        }
        return URL.documentsDirectory.appending(path: originalFilePath)
    }

    var reversedURL: URL? {
        guard let path = reversedFilePath else { return nil }
        if path.hasPrefix("/") {
            return URL(fileURLWithPath: path)
        }
        return URL.documentsDirectory.appending(path: path)
    }

    init(
        name: String,
        sourceType: AudioSourceType,
        originalFilePath: String,
        reversedFilePath: String? = nil,
        duration: TimeInterval,
        createdDate: Date = .now,
        itemURL: URL? = nil
    ) {
        self.name = name
        self.sourceType = sourceType
        self.originalFilePath = originalFilePath
        self.reversedFilePath = reversedFilePath
        self.duration = duration
        self.createdDate = createdDate
        self.itemURL = itemURL
    }
}
