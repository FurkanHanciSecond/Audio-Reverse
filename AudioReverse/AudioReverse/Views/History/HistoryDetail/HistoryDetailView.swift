//
//  HistoryDetailView.swift
//  AudioReverse
//
//  Created by Furkan Hanci on 4/2/26.
//

import SwiftUI
import WaveformScrubber

struct HistoryDetailView: View {
    let item: AudioHistoryItem
    @State private var progress: CGFloat = 0.25

    var body: some View {
        VStack {
            Text("Playback Progress: \(Int(progress * 100))%")

            WaveformScrubber(config: .init(activeTint: .blue, inactiveTint: .black), drawer: BarDrawer(), url: item.itemURL!, progress: $progress)
                .frame(height: 100)
                .padding()

            // Control the progress from outside
            Slider(value: $progress)
                .padding()
        }
    }
}
