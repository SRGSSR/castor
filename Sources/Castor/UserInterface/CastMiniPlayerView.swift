//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

private struct _CastMiniPlayerView: View {
    @ObservedObject var player: CastPlayer
    let cast: Cast

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
        ArtworkImage(url: metadata?.imageUrl(matching: .init(type: .miniController)))
    }

    private func infoView(with metadata: CastMetadata?) -> some View {
        ViewThatFits(in: .vertical) {
            regularInfoView(with: metadata)
            compactInfoView(with: metadata)
        }
    }

    private func playbackButton() -> some View {
        PlaybackButton(player: player)
            .font(.system(size: 40))
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
            .font(.subheadline)
            .bold()
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
