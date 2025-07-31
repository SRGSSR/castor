//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVKit
import Castor
import PillarboxPlayer
import SwiftUI

private struct PlaybackButton: View {
    let shouldPlay: Bool
    let action: () -> Void

    var body: some View {
        Button {
            action()
        } label: {
            Image(systemName: shouldPlay ? "pause.fill" : "play.fill")
        }
        .font(.system(size: 44))
    }

    init(shouldPlay: Bool, perform action: @escaping () -> Void) {
        self.shouldPlay = shouldPlay
        self.action = action
    }
}

private struct LocalPlayerView: View {
    @ObservedObject var player: Player

    var body: some View {
        ZStack {
            if let error = player.error {
                Text(error.localizedDescription)
            }
            else {
                if player.mediaType == .video {
                    VideoView(player: player)
                        .background(.black)
                }
                else {
                    LazyImage(source: player.metadata.imageSource) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    }
                }
                PlaybackButton(shouldPlay: player.shouldPlay, perform: player.togglePlayPause)
            }
        }
        .animation(.default, value: player.mediaType)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct RemotePlayerView: View {
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

struct PlayerView: View {
    let media: Media?

    @EnvironmentObject private var cast: Cast
    @State private var model = PlayerViewModel()

    @State private var isSelectionPresented = false
    @Environment(\.dismiss) private var dismiss

    @AppStorage(UserDefaults.DemoSettingKey.playerType)
    private var playerType: PlayerType = .standard

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
            switch playerType {
            case .standard:
                CastPlayerView(cast: cast)
            case .custom:
                RemotePlayerView(player: remotePlayer)
            }
        }
        else {
            LocalPlayerView(player: model.player)
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
