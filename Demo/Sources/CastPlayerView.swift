//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Castor
import CoreMedia
import GoogleCast
import SwiftUI

private struct MainView: View {
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

    @ObservedObject var player: CastPlayer
    let device: CastDevice?

    var body: some View {
        VStack {
            currentItemView()
            playlist()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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

    private var progress: Float? {
        let time = player.time()
        let timeRange = player.seekableTimeRange()
        guard time.isValid, timeRange.isValid, !timeRange.isEmpty else { return nil }
        return Float(time.seconds / timeRange.duration.seconds).clamped(to: 0...1)
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
    private func progressView() -> some View {
        HStack {
            if let elapsedTime = Self.formattedTime(player.time(), duration: player.seekableTimeRange().duration) {
                Text(elapsedTime)
            }
            if let progress {
                ProgressView(value: progress)
            }
            if let totalTime = Self.formattedTime(player.seekableTimeRange().duration, duration: player.seekableTimeRange().duration) {
                Text(totalTime)
            }
        }
        .frame(height: 30)
    }

    private func playbackButton() -> some View {
        Button(action: player.togglePlayPause) {
            Image(systemName: imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
        }
    }

    private func stopButton() -> some View {
        Button(action: player.stop) {
            Image(systemName: "stop.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
        }
    }

    private func buttons() -> some View {
        HStack(spacing: 40) {
            playbackButton()
            stopButton()
        }
        .frame(height: 60)
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
            progressView()
            buttons()
        }
        .padding()
    }

    private func currentItemView() -> some View {
        VStack {
            informationView()
            visualView()
            controls()
        }
    }

    private func playlist() -> some View {
        MediaQueueView(mediaQueue: player.queue)
    }
}

private struct MediaQueueView: View {
    @ObservedObject var mediaQueue: MediaQueue

    var body: some View {
        List(mediaQueue.items, id: \.self) { item in
            MediaQueueCell(item: item)
                .onAppear {
                    mediaQueue.load(item)
                }
        }
    }
}

private struct MediaQueueCell: View {
    let item: CastPlayerItem

    var body: some View {
        Text(item.title ?? String(repeating: " ", count: .random(in: 20...40)))
            .redacted(reason: item.title == nil ? .placeholder : [])
    }
}

struct CastPlayerView: View {
    @EnvironmentObject private var cast: Cast

    var body: some View {
        ZStack {
            if let player = cast.player {
                MainView(player: player, device: cast.currentDevice)
            }
            else {
                ContentUnavailableView("Not connected", systemImage: "wifi.slash")
                    .overlay(alignment: .topTrailing) {
                        ProgressView()
                            .padding()
                            .opacity(cast.connectionState == .connecting ? 1 : 0)
                    }
            }
        }
        .animation(.default, value: cast.player)
    }
}

#Preview {
    CastPlayerView()
        .environmentObject(Cast())
}
