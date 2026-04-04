//
//  RecordWidget.swift
//  RecordWidget
//
//  Created by Furkan Hanci on 4/4/26.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        completion(SimpleEntry(date: Date()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let entry = SimpleEntry(date: Date())
        let timeline = Timeline(entries: [entry], policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
}

struct RecordWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: "microphone.circle.fill")
                .resizable()
                .scaledToFit()
                .foregroundStyle(.white)
                .frame(width: 40, height: 40)

            Text("Record")
                .font(.system(size: 30))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
        }
    }
}

struct RecordWidget: Widget {
    let kind: String = "RecordWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            RecordWidgetEntryView(entry: entry)
                .containerBackground(for: .widget, content: {
                    LinearGradient(colors: [Color(white: 0.08), Color(white: 0.18), Color(white: 0.1)], startPoint: .topLeading, endPoint: .bottomTrailing)
                })
                .widgetAccentable(true)
        }
        .configurationDisplayName("Record Widget")
        .description("Easy Access From Your Home Screen")
        .supportedFamilies([.systemSmall])
    }
}
