//
//  VideoTransferable.swift
//  AudioReverse
//
//  Created by Furkan Hanci on 4/3/26.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers

struct VideoTransferable: Transferable {
    let url: URL

    static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(contentType: .movie) { video in
            SentTransferredFile(video.url)
        } importing: { received in
            let destination = URL.documentsDirectory
                .appending(path: "VideoImported")
                .appending(path: "\(UUID().uuidString).mov")

            let folder = destination.deletingLastPathComponent()
            if !FileManager.default.fileExists(atPath: folder.path()) {
                try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
            }

            try FileManager.default.copyItem(at: received.file, to: destination)
            return VideoTransferable(url: destination)
        }
    }
}
