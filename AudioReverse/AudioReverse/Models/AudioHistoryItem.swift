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
    var originalFilePath: String
    var reversedFilePath: String?
    var duration: TimeInterval
    var createdDate: Date
    var itemURL: URL?

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
