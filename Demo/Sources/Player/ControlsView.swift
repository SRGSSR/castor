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

    @EnvironmentObject private var cast: Cast
    @StateObject private var progressTracker = CastProgressTracker(interval: .init(value: 1, timescale: 10))
    @ObservedObject var player: CastPlayer
    let device: CastDevice?

    var body: some View {
        VStack {
            informationView()
            visualView()
            controls()
        }
        .disabled(!player.isActive)
        .bind(progressTracker, to: player)
    }

    private var imageName: String {
        player.shouldPlay ? "pause.fill" : "play.fill"
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
        .frame(height: 100)
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

    private func slider() -> some View {
        HStack {
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
                if player.mediaInformation?.streamType == .live {
                    skipToDefaultButton()
                }
            }
        }
        .frame(height: 30)
    }

    @ViewBuilder
    private func label(withText text: String?) -> some View {
        if let text {
            Text(text)
                .font(.caption)
                .monospacedDigit()
                .foregroundColor(.primary)
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

private extension ControlsView {
    private static let side: CGFloat = 40

    private func skipBackwardButton() -> some View {
        Button(action: player.skipBackward) {
            Image.goBackward(withInterval: cast.configuration.backwardSkipInterval)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: Self.side)
        }
        .frame(width: Self.side)
        .disabled(!player.canSkipBackward())
    }

    private func playbackButton() -> some View {
        Button(action: player.togglePlayPause) {
            Image(systemName: imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: Self.side)
        }
        .frame(width: Self.side)
    }

    private func skipForwardButton() -> some View {
        Button(action: player.skipForward) {
            Image.goForward(withInterval: cast.configuration.forwardSkipInterval)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: Self.side)
        }
        .frame(width: Self.side)
        .disabled(!player.canSkipForward())
    }

    private func skipToDefaultButton() -> some View {
        Button(action: player.skipToDefault) {
            Image(systemName: "forward.end.fill")
                .font(.system(size: 20))
        }
        .disabled(!player.canSkipToDefault())
    }

    func buttons() -> some View {
        HStack(spacing: 50) {
            skipBackwardButton()
            playbackButton()
            skipForwardButton()
        }
    }
}
