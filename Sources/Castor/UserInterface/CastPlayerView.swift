//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

private enum GeometryEffectIdentifier: Hashable {
    case artwork
    case info
}

private struct _CastPlayerView: View {
    @ObservedObject var player: CastPlayer
    let device: CastDevice?

    @State private var isPlaylistPresented = false
    @Namespace var namespace
    @Environment(\.verticalSizeClass) private var verticalSizeClass

    var body: some View {
        if verticalSizeClass == .compact {
            HStack(spacing: 0) {
                VStack {
                    HStack(spacing: 20) {
                        visualView()
                        informationView()
                    }
                    .frame(height: 100)
                    Spacer()
                    ControlsView(player: player, isPlaylistPresented: $isPlaylistPresented)
                }
                PlaylistView(player: player)
            }
        }
        else {
            VStack(spacing: 0) {
                if isPlaylistPresented {
                    HStack(spacing: 20) {
                        visualView()
                        informationView()
                    }
                    .frame(height: 100)
                    .padding([.horizontal, .top])
                    PlaylistView(player: player)
                        .transition(.move(edge: .bottom))
                }
                else {
                    Spacer()
                    visualView()
                        .padding()
                    Spacer()
                    informationView()
                        .padding(.horizontal)
                }
                ControlsView(player: player, isPlaylistPresented: $isPlaylistPresented)
            }
            .animation(.default, value: isPlaylistPresented)
        }
    }

    private func artworkImage() -> some View {
        ArtworkImage(url: player.metadata?.imageUrl())
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

    private func informationView() -> some View {
        VStack(alignment: .leading) {
            LiveLabel(player: player)
            if let title = player.metadata?.title {
                Text(title)
                    .bold()
            }
            if let device {
                Text("Connected to \(device.name ?? "receiver")")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .matchedGeometryEffect(id: GeometryEffectIdentifier.info, in: namespace)
    }

    private func visualView() -> some View {
        ZStack {
            artworkImage()
            loadingIndicator()
        }
        .matchedGeometryEffect(id: GeometryEffectIdentifier.artwork, in: namespace)
    }
}

/// A cast player view.
public struct CastPlayerView: View {
    @ObservedObject private var cast: Cast

    // swiftlint:disable:next missing_docs
    public var body: some View {
        if let player = cast.player {
            _CastPlayerView(player: player, device: cast.currentDevice)
        }
        else {
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    // swiftlint:disable:next missing_docs
    public init(cast: Cast) {
        self.cast = cast
    }
}
