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
                artwork(for: player.currentAsset)
                infoView(for: player.currentAsset)
                Spacer()
                playbackButton()
            }
            .contentShape(.rect)
        }
    }

    private func artwork(for asset: CastAsset?) -> some View {
        ArtworkImage(url: asset?.metadata?.imageUrl(matching: .init(type: .miniController)))
    }

    private func infoView(for asset: CastAsset?) -> some View {
        ViewThatFits(in: .vertical) {
            regularInfoView(for: asset)
            compactInfoView(for: asset)
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
    func regularInfoView(for asset: CastAsset?) -> some View {
        VStack(alignment: .leading) {
            title(for: asset)
            subtitle()
        }
    }

    func compactInfoView(for asset: CastAsset?) -> some View {
        title(for: asset)
            .minimumScaleFactor(0.7)
    }

    private func title(for asset: CastAsset?) -> some View {
        Text(asset?.metadata?.title ?? "Untitled")
            .font(.subheadline)
            .bold()
            .lineLimit(1)
    }

    @ViewBuilder
    private func subtitle() -> some View {
        if let deviceName = cast.currentDevice?.name {
            Text("Casting on \(deviceName)", bundle: .module, comment: "Current Cast receiver (with device name as wildcard)")
                .foregroundStyle(.secondary)
                .font(.subheadline)
                .lineLimit(1)
        }
    }
}
