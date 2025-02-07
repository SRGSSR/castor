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
            HStack(spacing: 40) {
                playbackButton()
                stopButton()
            }
            informationView()
        }
    }

    private var imageName: String {
        player.state == .playing ? "pause.circle.fill" : "play.circle.fill"
    }

    private var title: String? {
        player.mediaInformation?.metadata?.string(forKey: kGCKMetadataKeyTitle)
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
