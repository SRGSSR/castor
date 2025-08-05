//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVKit
import Castor
import PillarboxPlayer
import SwiftUI

private struct RemotePlaybackView: View {
    @ObservedObject var player: CastPlayer

    var body: some View {
        ZStack {
            artwork()
            PlaybackButton(shouldPlay: player.shouldPlay, perform: player.togglePlayPause)
        }
    }

    private func artwork() -> some View {
        AsyncImage(url: player.metadata?.imageUrl()) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fit)
        } placeholder: {
            EmptyView()
        }
    }
}

struct UnifiedPlayerView: View {
    let media: Media?

    @EnvironmentObject private var cast: Cast
    @State private var model = PlayerViewModel()

    @State private var isSelectionPresented = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            mainView()
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        closeButton()
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        addButton()
                    }
                    ToolbarItem(placement: .topBarTrailing) { // TODO: Should be removed!
                        CastButton(cast: cast)
                    }
                }
                .toolbarBackground(.background, for: .navigationBar)
        }
        .sheet(isPresented: $isSelectionPresented) {
            NavigationStack {
                PlaylistSelectionView(player: cast.player)
            }
        }
        .onAppear {
            guard let media else { return }
            if let remotePlayer = cast.player {
                remotePlayer.loadItem(from: media.asset())
            }
            else {
                model.content = .init(medias: [media])
                model.play()
            }
        }
        .makeCastable(model, with: cast)
    }

    @ViewBuilder
    func mainView() -> some View {
        if let remotePlayer = cast.player {
            RemotePlaybackView(player: remotePlayer)
        }
        else {
            LocalPlaybackView(player: model.player)
        }
    }

    private func addButton() -> some View {
        Button {
            isSelectionPresented.toggle()
        } label: {
            Image(systemName: "plus")
        }
    }

    private func closeButton() -> some View {
        Button {
            dismiss()
        } label: {
            Text("Close")
        }
    }
}
