//
//  MediaProcessingService.swift
//  AudioReverse
//
//  Created by Furkan Hanci on 4/3/26.
//

import Foundation
import AVFoundation

enum MediaProcessingError: Error {
    case exportSessionCreationFailed
    case outputURLMissing
    case exportFailed(Error?)
    case directoryCreationFailed(Error)
}

enum MediaProcessingService {
    static func extractAudio(from videoAsset: AVURLAsset) async throws -> URL {
        let exportSessionID = UUID().uuidString

        guard let exportSession = AVAssetExportSession(asset: videoAsset, presetName: AVAssetExportPresetAppleM4A) else {
            throw MediaProcessingError.exportSessionCreationFailed
        }

        let folderURL = URL.documentsDirectory.appending(path: "VideoExtracted/\(exportSessionID)")

        do {
            try FileManager.default.createDirectory(at: folderURL, withIntermediateDirectories: true)
        } catch {
            throw MediaProcessingError.directoryCreationFailed(error)
        }

        let outputURL = folderURL.appending(path: "audio\(exportSessionID).m4a")

        exportSession.outputFileType = .m4a
        exportSession.outputURL = outputURL

        try? await exportSession.export(to: outputURL, as: .m4a)

        switch exportSession.status {
        case .completed:
            if let url = exportSession.outputURL {
                return url
            } else {
                throw MediaProcessingError.outputURLMissing
            }
        case .failed, .cancelled:
            throw MediaProcessingError.exportFailed(exportSession.error)
        default:
            throw MediaProcessingError.outputURLMissing
        }
    }
}
