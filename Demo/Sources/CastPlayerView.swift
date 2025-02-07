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
            artworkImage()
            progressView()
            controls()
            informationView()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.black)
    }

    private var imageName: String {
        player.state == .playing ? "pause.circle.fill" : "play.circle.fill"
    }

    private var title: String? {
        player.mediaInformation?.metadata?.string(forKey: kGCKMetadataKeyTitle)
    }

    private var imageUrl: URL? {
        guard let image = player.mediaInformation?.metadata?.images().first as? GCKImage else { return nil }
        return image.url
    }

    private var progress: Float? {
        let time = player.time
        let duration = player.duration
        guard time.isValid, duration.isValid else { return nil }
        return Float(time.seconds / duration.seconds)
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
    private func progressView() -> some View {
        HStack {
            if let elapsedTime = Self.formattedTime(player.time, duration: player.duration) {
                Text(elapsedTime)
            }
            if let progress {
                ProgressView(value: progress)
            }
            if let totalTime = Self.formattedTime(player.duration, duration: player.duration) {
                Text(totalTime)
            }
        }
    }

    private func playbackButton() -> some View {
        Button(action: player.togglePlayPause) {
            Image(systemName: imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 90)
        }
    }

    private func stopButton() -> some View {
        Button(action: player.stop) {
            Image(systemName: "stop.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 90)
        }
    }

    private func controls() -> some View {
        HStack(spacing: 40) {
            playbackButton()
            stopButton()
        }
        .foregroundStyle(.white)
    }

    private func informationView() -> some View {
        VStack {
            if let title {
                Text(title)
            }
            if let device = player.device {
                Text("Connected to \(device.friendlyName ?? "receiver")")
            }
        }
        .foregroundStyle(.white)
    }
}

#Preview {
    CastPlayerView()
}
