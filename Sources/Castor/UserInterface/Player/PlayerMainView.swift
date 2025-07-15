//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import GoogleCast
import SwiftUI

private enum GeometryEffectIdentifier: Hashable {
    case artwork
    case info
}

struct PlayerMainView: View {
    @ObservedObject var player: CastPlayer
    let device: CastDevice?

    @State private var isPlaylistPresented = false
    @Namespace var namespace

    var body: some View {
        VStack {
            if isPlaylistPresented {
                HStack {
                    visualView()
                    informationView()
                }
                .frame(height: 100)
                PlaylistView(player: player)
                        .transition(.move(edge: .bottom))
            }
            else {
                Spacer()
                visualView()
                Spacer()
                informationView()
            }
            ControlsView(player: player, isPlaylistPresented: $isPlaylistPresented)
        }
        .animation(.default, value: isPlaylistPresented)
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
        .padding()
        .matchedGeometryEffect(id: GeometryEffectIdentifier.artwork, in: namespace)
    }
}
