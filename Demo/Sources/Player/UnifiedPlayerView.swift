//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVKit
import Castor
import PillarboxPlayer
import SwiftUI

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
                    ToolbarItem(placement: .topBarTrailing) {
                        CastButton(cast: cast)
                    }
                }
        }
        .sheet(isPresented: $isSelectionPresented) {
            NavigationStack {
                PlaylistSelectionView { option, medias in
                    if let remotePlayer = cast.player {
                        remotePlayer.add(option, medias: medias)
                    }
                    else {
                        model.add(option, medias: medias)
                    }
                }
            }
        }
        .onAppear {
            guard let media else { return }
            if let remotePlayer = cast.player {
                remotePlayer.loadItem(from: media.asset())
            }
            else {
                model.entries = [.init(media: media)]
                model.play()
            }
        }
        .makeCastable(model, with: cast)
    }

    @ViewBuilder
    func mainView() -> some View {
        ZStack {
            if let remotePlayer = cast.player {
                RemotePlaybackView(player: remotePlayer)
            }
            else {
                LocalPlaybackView(model: model, player: model.player)
            }
        }
        .animation(.default, value: cast.player)
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
