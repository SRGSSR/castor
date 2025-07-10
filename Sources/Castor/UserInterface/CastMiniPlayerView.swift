//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

private struct _CastMiniPlayerView: View {
    @ObservedObject var player: CastPlayer
    let cast: Cast

    private var imageName: String {
        player.shouldPlay ? "pause.fill" : "play.fill"
    }

    var body: some View {
        if ![.idle, .unknown].contains(player.state) {
            HStack(spacing: 20) {
                artwork(with: player.metadata)
                infoView(with: player.metadata)
                Spacer()
                playbackButton()
            }
            .contentShape(.rect)
        }
    }

    @ViewBuilder
    private func artwork(with metadata: CastMetadata?) -> some View {
        Rectangle()
            .fill(.primary.opacity(0.2))
            .aspectRatio(contentMode: .fit)
            .overlay {
                AsyncImage(url: metadata?.imageUrl()) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    EmptyView()
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 5))
    }

    private func infoView(with metadata: CastMetadata?) -> some View {
        ViewThatFits(in: .vertical) {
            regularInfoView(with: metadata)
            compactInfoView(with: metadata)
        }
    }

    private func playbackButton() -> some View {
        Button(action: player.togglePlayPause) {
            Image(systemName: imageName)
                .resizable()
                .transaction { $0.animation = nil }
                .aspectRatio(contentMode: .fit)
        }
        .frame(maxHeight: 30)
    }
}

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

private extension _CastMiniPlayerView {
    func regularInfoView(with metadata: CastMetadata?) -> some View {
        VStack(alignment: .leading) {
            title(with: metadata)
            subtitle()
        }
    }

    func compactInfoView(with metadata: CastMetadata?) -> some View {
        title(with: metadata)
            .minimumScaleFactor(0.7)
    }

    private func title(with metadata: CastMetadata?) -> some View {
        Text(metadata?.title ?? "Untitled")
            .fontWeight(.bold)
            .font(.subheadline)
            .lineLimit(1)
    }

    @ViewBuilder
    private func subtitle() -> some View {
        if let deviceName = cast.currentDevice?.name {
            Text("Casting on \(deviceName)")
                .foregroundStyle(.secondary)
                .font(.subheadline)
                .lineLimit(1)
        }
    }
}
