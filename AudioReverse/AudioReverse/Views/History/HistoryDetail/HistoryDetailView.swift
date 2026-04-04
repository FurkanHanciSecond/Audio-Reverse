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

    @Environment(UserDefaultsManager.self) private var userDefaultsManager
    @State private var player = AudioPlayer()
    @State private var progress: CGFloat = 0
    @State private var isDragging = false
    @State private var isReversed = false
    @State private var speed: Double = 1.0
    @State private var pitchSemitones: Double = 0
    @State private var shareURL: URL?
    @State private var showPaywall = false

    private var activeURL: URL {
        isReversed ? (item.reversedURL ?? item.originalURL) : item.originalURL
    }

    private var displayDuration: TimeInterval {
        player.duration > 0 ? player.duration : item.duration
    }

    var body: some View {
        VStack(spacing: 28) {
            waveformSection
            transportSection
            speedSection
            pitchSection
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.ignoresSafeArea())
        .navigationTitle(item.name)
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: player.currentTime) { _, time in
            guard !isDragging, player.duration > 0 else { return }
            progress = CGFloat(time / player.duration)
        }
        .onChange(of: player.isPlaying) { _, playing in
            if !playing { progress = 0 }
        }
        .onDisappear { player.stop() }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu("Share", systemImage: "square.and.arrow.up") {
                    Button("Original", systemImage: "waveform") {
                        shareURL = item.originalURL
                        OperationQueue.main.addOperation {
                            let shareActivity = UIActivityViewController(activityItems: [shareURL as Any], applicationActivities: nil)
                            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                                  let window = windowScene.windows.first,
                                  let vc = window.rootViewController else {
                                return
                            }
                            shareActivity.popoverPresentationController?.sourceView = vc.view
                            shareActivity.popoverPresentationController?.sourceRect = CGRect(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height, width: 0, height: 0)
                            shareActivity.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.down
                            vc.present(shareActivity, animated: true, completion: nil)
                        }
                    }

                    if let reversedURL = item.reversedURL {
                        Button("Reversed", systemImage: "arrow.uturn.backward") {
                            shareURL = reversedURL
                            OperationQueue.main.addOperation {
                                let shareActivity = UIActivityViewController(activityItems: [reversedURL], applicationActivities: nil)
                                guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                                      let window = windowScene.windows.first,
                                      let vc = window.rootViewController else {
                                    return
                                }
                                shareActivity.popoverPresentationController?.sourceView = vc.view
                                shareActivity.popoverPresentationController?.sourceRect = CGRect(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height, width: 0, height: 0)
                                shareActivity.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.down
                                vc.present(shareActivity, animated: true, completion: nil)
                            }
                        }
                    }
                }
            }
        }
    }

    // MARK: - Waveform

    private var waveformSection: some View {
        VStack(spacing: 10) {
            WaveformScrubber(
                config: .init(activeTint: .blue, inactiveTint: .gray.opacity(0.5)),
                drawer: BarDrawer(),
                url: activeURL,
                progress: .constant(progress)
            )
            .frame(height: 120)
            .padding(14)
            .background(Color(white: 0.1), in: RoundedRectangle(cornerRadius: 16))

            HStack {
                Text(formatTime(player.currentTime))
                    .font(.system(.caption, design: .monospaced))
                    .foregroundStyle(.white.opacity(0.5))
                Spacer()
                Text(formatTime(displayDuration))
                    .font(.system(.caption, design: .monospaced))
                    .foregroundStyle(.white.opacity(0.5))
            }

            Slider(value: $progress, in: 0...1) { editing in
                isDragging = editing
                if !editing {
                    player.seek(to: Double(progress) * player.duration)
                }
            }
            .tint(.white)
        }
    }

    // MARK: - Transport

    private var transportSection: some View {
        HStack(spacing: 52) {
            transportButton(
                icon: "arrow.uturn.backward",
                label: "Reverse",
                isActive: isReversed,
                action: toggleReverse
            )

            Button(action: togglePlay) {
                Image(systemName: player.isPlaying ? "stop.fill" : "play.fill")
                    .font(.system(size: 26, weight: .medium))
                    .foregroundStyle(.white)
                    .frame(width: 68, height: 68)
                    .background(.blue, in: Circle())
            }

            transportButton(
                icon: "repeat",
                label: "Loop",
                isActive: player.isLooping,
                action: { player.isLooping.toggle() }
            )
        }
    }

    private func transportButton(
        icon: String,
        label: String,
        isActive: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(isActive ? .blue : .white)
                Text(label)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.7))
            }
        }
    }

    // MARK: - Speed

    private var speedSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Speed")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundStyle(.white)

            HStack(spacing: 10) {
                Text("0.5x")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.5))

                Slider(value: $speed, in: 0.5...2.0) { _ in
                    player.rate = Float(speed)
                }
                .tint(.blue)

                Text("2.0x")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.5))
            }

            Text(String(format: "%.1fx", speed))
                .font(.caption)
                .foregroundStyle(.white.opacity(0.5))
                .frame(maxWidth: .infinity, alignment: .center)
        }
    }

    // MARK: - Pitch

    private var pitchSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Pitch")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundStyle(.white)

            HStack(spacing: 10) {
                Text("😈")
                    .font(.system(size: 20))

                Slider(value: $pitchSemitones, in: -12...12, step: 1) { _ in
                    player.pitch = Float(pitchSemitones * 100)
                }
                .tint(.blue)

                Text("🐿️")
                    .font(.system(size: 20))
            }

            Text(pitchSemitones == 0 ? "0 st" : String(format: "%+.0f st", pitchSemitones))
                .font(.caption)
                .foregroundStyle(.white.opacity(0.5))
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .disabled(!userDefaultsManager.isPremium)
        .overlay {
            if !userDefaultsManager.isPremium {
                VStack(spacing: 8) {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 28))
                        .foregroundStyle(.gray)

                    Text("Pro")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)
                }
                .frame(width: 64, height: 64)
                .compatibleCircularGlassEffect(interactiveEnabled: true)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .foregroundStyle(.black)
                        .opacity(0.1)
                )
                .onTapGesture {
                    showPaywall = true
                }
            }
        }
        .fullScreenCover(isPresented: $showPaywall) {
            PaywallView()
        }
    }

    // MARK: - Actions

    private func togglePlay() {
        UIImpactFeedbackGenerator().impactOccurred()
        if player.isPlaying {
            player.stop()
        } else {
            player.rate = Float(speed)
            player.pitch = Float(pitchSemitones * 100)
            player.play(url: activeURL)
        }
    }

    private func toggleReverse() {
        let wasPlaying = player.isPlaying
        player.stop()
        progress = 0
        isReversed.toggle()
        if wasPlaying {
            player.rate = Float(speed)
            player.pitch = Float(pitchSemitones * 100)
            player.play(url: activeURL)
        }
    }

    // MARK: - Helpers

    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        let centiseconds = Int((time.truncatingRemainder(dividingBy: 1)) * 100)
        return String(format: "%02d:%02d.%02d", minutes, seconds, centiseconds)
    }
}

#Preview {
    HistoryDetailView(item: AudioHistoryItem(
        name: "Sample Recording",
        sourceType: .recording,
        originalFilePath: "Recordings/sample.wav",
        duration: 90
    ))
}
