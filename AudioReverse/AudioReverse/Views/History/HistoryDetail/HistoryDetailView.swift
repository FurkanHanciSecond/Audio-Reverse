//
//  HistoryDetailView.swift
//  AudioReverse
//
//  Created by Furkan Hanci on 4/2/26.
//

import SwiftUI

struct HistoryDetailView: View {
    let item: AudioHistoryItem

    var body: some View {
        Text("History Detail \(item.sourceType)")
    }
}

#Preview {
    HistoryDetailView(item: AudioHistoryItem(
        name: "Sample Recording",
        sourceType: .recording,
        originalFilePath: "",
        duration: 90
    ))
}
