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
                if !player.items.isEmpty {
                    PlaylistView(player: player)
                        .transition(.move(edge: .trailing))
                }
            }
            .animation(.default, value: player.items.isEmpty)
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
            .onChange(of: player.items) { items in
                if items.isEmpty {
                    isPlaylistPresented = false
                }
            }
        }
    }

    private func artworkImage() -> some View {
        ArtworkImage(url: player.metadata?.imageUrl())
            .scaleEffect(player.shouldPlay ? 1 : 0.95)
            .shadow(color: .primary.opacity(0.15), radius: 6, y: 3)
            .animation(.default, value: player.shouldPlay)
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
            informationTitle()
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

    private func informationTitle() -> some View {
        Group {
            if player.items.isEmpty {
                Text("Not Playing")
                    .foregroundStyle(.secondary)
            }
            else {
                Text(player.metadata?.title ?? "Untitled")
            }
        }
        .bold()
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
            VStack(spacing: 20) {
                ProgressView()
                if let deviceName = cast.currentDevice?.name {
                    Text("Connecting to \(deviceName)")
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    // swiftlint:disable:next missing_docs
    public init(cast: Cast) {
        self.cast = cast
    }
}
