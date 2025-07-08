//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

/// A mini cast player view.
public struct CastMiniPlayerView: View {
    @ObservedObject private var cast: Cast

    // swiftlint:disable:next missing_docs
    public var body: some View {
        if let player = cast.player {
            _CastMiniPlayerView(player: player, cast: cast)
        }
    }

    // swiftlint:disable:next missing_docs
    public init(cast: Cast) {
        self.cast = cast
    }
}

private struct _CastMiniPlayerView: View {
    @ObservedObject var player: CastPlayer
    let cast: Cast

    private var imageName: String {
        player.shouldPlay ? "pause.fill" : "play.fill"
    }

    var body: some View {
        if let metadata = player.metadata {
            HStack(spacing: 20) {
                artwork(with: metadata)
                infoView(with: metadata)
                Spacer()
                playbackButton()
            }
        }
    }

    private func artwork(with metadata: CastMetadata) -> some View {
        Rectangle()
            .aspectRatio(contentMode: .fit)
            .overlay {
                AsyncImage(url: metadata.imageUrl()) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    EmptyView()
                }
            }
            .roundedBorder(cornerRadius: 5, lineWidth: 1, color: .primary.opacity(0.2))
    }

    private func infoView(with metadata: CastMetadata) -> some View {
        VStack(alignment: .leading) {
            Text(metadata.title ?? "Not playing")
                .fontWeight(.bold)
            if let deviceName = cast.currentDevice?.name {
                Text("Casting on \(deviceName)")
                    .foregroundStyle(.secondary)
            }
        }
        .font(.subheadline)
        .minimumScaleFactor(0.7)
    }

    private func playbackButton() -> some View {
        Button(action: player.togglePlayPause) {
            Image(systemName: imageName)
                .resizable()
                .transaction { $0.animation = nil }
                .aspectRatio(contentMode: .fit)
                .frame(height: 30)
        }
        .frame(width: 30)
    }
}

private extension View {
    func roundedBorder(cornerRadius: CGFloat, lineWidth: CGFloat, color: Color) -> some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius)
        return clipShape(shape)
            .overlay {
                shape
                    .stroke(lineWidth: lineWidth)
                    .foregroundStyle(color)
            }
    }
}
