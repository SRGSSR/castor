//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

private struct _CastMiniPlayerView: View {
    @ObservedObject var player: CastPlayer
    @ObservedObject var cast: Cast

    var body: some View {
        HStack(spacing: 20) {
            artwork(for: player.currentAsset)
            infoView(for: player.currentAsset)
            Spacer()
            playbackButton()
        }
        .contentShape(.rect)
    }

    private func artwork(for asset: CastAsset?) -> some View {
        ArtworkImage(url: asset?.metadata?.imageUrl(matching: .init(type: .miniController)))
    }

    private func infoView(for asset: CastAsset?) -> some View {
        ViewThatFits(in: .vertical) {
            regularInfoView(for: asset)
            compactInfoView(for: asset)
        }
        .accessibilityElement()
        .accessibilityLabel(accessibilityLabel)
    }

    private func playbackButton() -> some View {
        PlaybackButton(player: player)
            .font(.system(size: 40))
            .disabled(!player.isActive)
    }
}

/// A mini Cast player view.
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
        Text(CastAsset.name(for: asset))
            .font(.subheadline)
            .bold()
            .lineLimit(1)
    }

    private func subtitle() -> some View {
        Text(CastDevice.route(to: cast.currentDevice))
            .foregroundStyle(.secondary)
            .font(.subheadline)
            .lineLimit(1)
    }
}

private extension _CastMiniPlayerView {
    var accessibilityLabel: String {
        "\(CastAsset.name(for: player.currentAsset)), \(CastDevice.route(to: cast.currentDevice))"
    }
}
