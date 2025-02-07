//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Castor
import GoogleCast
import SwiftUI

struct CastPlayerView: View {
    @StateObject private var player = CastPlayer()

    var body: some View {
        VStack(spacing: 40) {
            artworkImage()
            progressView()
            HStack(spacing: 40) {
                playbackButton()
                stopButton()
            }
            informationView()
        }
        .padding()
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

    @ViewBuilder
    private func progressView() -> some View {
        if let progress {
            ProgressView(value: progress)
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

    private func informationView() -> some View {
        VStack {
            if let title {
                Text(title)
            }
            if let device = player.device {
                Text("Connected to \(device.friendlyName ?? "receiver")")
            }
        }
    }
}

#Preview {
    CastPlayerView()
}
