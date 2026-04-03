//
//  HistoryView.swift
//  AudioReverse
//
//  Created by Furkan Hanci on 4/2/26.
//

import SwiftUI
import SwiftData

enum HistoryViewFullScreens: Identifiable {

    var id: UUID {
        UUID()
    }

    case paywall
}

struct HistoryView: View {
    @Query(sort: \AudioHistoryItem.createdDate, order: .reverse)
    private var items: [AudioHistoryItem]
    @Environment(\.modelContext) private var modelContext
    @Environment(UserDefaultsManager.self) private var userDefaultsManager
    @State private var activeFullScreens: HistoryViewFullScreens?
    @State private var selectedItem: AudioHistoryItem?

    var body: some View {
        NavigationStack {
            Group {
                if items.isEmpty {
                    ContentUnavailableView {
                        Label("No History Yet", systemImage: "clock.fill")
                    } description: {
                        Text("Record or import audio to get started")
                    }
                } else {
                    historyList
                }
            }
            .navigationTitle("History")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black.ignoresSafeArea())
            .navigationDestination(item: $selectedItem) { item in
                HistoryDetailView(item: item)
            }
        }
        .fullScreenCover(item: $activeFullScreens) { screen in
            switch screen {
            case .paywall:
                PaywallView()
            }
        }
    }

    // MARK: - List

    private var historyList: some View {
        List {
            ForEach(items) { item in
                Button {
                    handleRowTapped(item)
                } label: {
                    historyRow(for: item)
                }
            }
            .onDelete(perform: deleteItems)
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
    }

    // MARK: - Row

    private func historyRow(for item: AudioHistoryItem) -> some View {
        HStack(spacing: 14) {
            sourceIcon(for: item.sourceType)

            VStack(alignment: .leading, spacing: 6) {
                Text(item.name)
                    .font(.headline)
                    .foregroundStyle(.white)
                    .lineLimit(1)

                HStack(spacing: 8) {
                    Text(item.sourceType == .recording ? "Recording" : "File import")
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundStyle(.white.opacity(0.7))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(.white.opacity(0.12), in: .capsule)

                    Text(formattedDuration(item.duration))
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.5))

                    Text(item.createdDate, format: .dateTime.month().day().year())
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.5))
                }
            }
        }
        .padding(.vertical, 8)
    }

    // MARK: - Source Icon

    private func sourceIcon(for sourceType: AudioSourceType) -> some View {
        Image(systemName: sourceType == .recording ? "mic.fill" : "doc.fill")
            .font(.title3)
            .foregroundStyle(.blue)
            .frame(width: 44, height: 44)
            .background(.blue.opacity(0.15), in: RoundedRectangle(cornerRadius: 10))
    }

    // MARK: - Actions

    private func handleRowTapped(_ item: AudioHistoryItem) {
        if !userDefaultsManager.isPremium && userDefaultsManager.remainingCount <= 0 {
            activeFullScreens = .paywall
        } else {
            selectedItem = item
        }
    }

    private func deleteItems(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(items[index])
        }
        try? modelContext.save()
    }

    // MARK: - Helpers

    private func formattedDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

#Preview {
    HistoryView()
        .modelContainer(for: AudioHistoryItem.self, inMemory: true)
}
