//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Castor
import CoreMedia
import GoogleCast
import SwiftUI

struct ControlsView: View {
    private static let shortFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.second, .minute]
        formatter.zeroFormattingBehavior = .pad
        return formatter
    }()

    private static let longFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.second, .minute, .hour]
        formatter.zeroFormattingBehavior = .pad
        return formatter
    }()

    @StateObject private var progressTracker = ProgressTracker(interval: .init(value: 1, timescale: 10))
    @ObservedObject var player: CastPlayer
    let device: CastDevice?

    var body: some View {
        VStack {
            informationView()
            visualView()
            controls()
        }
        .bind(progressTracker, to: player)
    }

    private var imageName: String {
        player.state == .playing ? "pause.fill" : "play.fill"
    }

    private var title: String? {
        player.mediaInformation?.metadata?.string(forKey: kGCKMetadataKeyTitle)
    }

    private var imageUrl: URL? {
        guard let image = player.mediaInformation?.metadata?.images().first as? GCKImage else { return nil }
        return image.url
    }

    private static func formattedTime(_ time: CMTime, duration: CMTime) -> String? {
        guard time.isValid, duration.isValid else { return nil }
        if duration.seconds < 60 * 60 {
            return shortFormatter.string(from: time.seconds)!
        }
        else {
            return longFormatter.string(from: time.seconds)!
        }
    }

    private func artworkImage() -> some View {
        AsyncImage(url: imageUrl) { image in
            image
                .resizable()
        } placeholder: {
            Image(systemName: "photo")
                .resizable()
        }
        .aspectRatio(contentMode: .fit)
        .frame(height: 160)
    }

    private func loadingIndicator() -> some View {
        ProgressView()
            .tint(.white)
            .padding(10)
            .background(
                Circle()
                    .fill(Color(white: 0, opacity: 0.4))
            )
            .opacity(player.isBusy ? 1 : 0)
            .animation(.default, value: player.isBusy)
    }

    @ViewBuilder
    private func slider() -> some View {
        if progressTracker.isProgressAvailable {
            Slider(
                progressTracker: progressTracker,
                label: {
                    Text("Current position")
                },
                minimumValueLabel: {
                    label(withText: Self.formattedTime(progressTracker.time, duration: progressTracker.timeRange.duration))
                },
                maximumValueLabel: {
                    label(withText: Self.formattedTime(progressTracker.timeRange.duration, duration: progressTracker.timeRange.duration))
                }
            )
            .frame(height: 30)
        }
    }

    @ViewBuilder
    private func label(withText text: String?) -> some View {
        if let text {
            Text(text)
                .font(.caption)
                .monospacedDigit()
                .foregroundColor(.white)
        }
    }

    private func playbackButton() -> some View {
        Button(action: player.togglePlayPause) {
            Image(systemName: imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 60)
        }
        .frame(width: 60)
    }

    private func stopButton() -> some View {
        Button(action: player.stop) {
            Image(systemName: "stop.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 60)
        }
        .frame(width: 60)
    }

    private func buttons() -> some View {
        HStack(spacing: 40) {
            playbackButton()
            stopButton()
        }
    }

    private func informationView() -> some View {
        VStack {
            if let title {
                Text(title)
            }
            if let device {
                Text("Connected to \(device.name ?? "receiver")")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func visualView() -> some View {
        ZStack {
            artworkImage()
            loadingIndicator()
        }
        .padding()
    }

    private func controls() -> some View {
        VStack {
            slider()
            buttons()
        }
        .padding()
    }
}
