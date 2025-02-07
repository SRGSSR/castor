//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Castor
import CoreMedia
import GoogleCast
import SwiftUI

struct CastPlayerView: View {
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

    @StateObject private var player = CastPlayer()

    var body: some View {
        VStack(spacing: 40) {
            informationView()
            Spacer()
            ZStack {
                artworkImage()
                loadingIndicator()
            }
            Spacer()
            controls()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.black)
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
        return Float(time.seconds / timeRange.duration.seconds)
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
                .foregroundStyle(.white)
        }
        .aspectRatio(contentMode: .fit)
        .frame(height: 160)
    }

    @ViewBuilder
    private func loadingIndicator() -> some View {
        if player.isBusy {
            ProgressView()
                .tint(.white)
                .padding(10)
                .background(
                    Circle()
                        .fill(Color(white: 0, opacity: 0.4))
                )
        }
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
        .foregroundStyle(.white)
        .frame(height: 60)
    }

    private func controls() -> some View {
        VStack {
            progressView()
            buttons()
        }
    }

    private func informationView() -> some View {
        VStack {
            if let title {
                Text(title)
            }
            if let device = player.device {
                Text("Connected to \(device.friendlyName ?? "receiver")")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .foregroundStyle(.white)
    }
}

#Preview {
    CastPlayerView()
}
