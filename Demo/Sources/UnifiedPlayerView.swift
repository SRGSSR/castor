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
                    ToolbarItem(placement: .topBarTrailing) { // TODO: Should be removed!
                        CastButton(cast: cast)
                    }
                }
                .toolbarBackground(.background, for: .navigationBar)
        }
        .sheet(isPresented: $isSelectionPresented) {
            NavigationStack {
                PlaylistSelectionView { option, medias in
                    if let remotePlayer = cast.player {
                        let assets = medias.map { $0.asset() }
                        switch option {
                        case .prepend:
                            remotePlayer.prependItems(from: assets)
                        case .insertBefore:
                            remotePlayer.insertItems(from: assets, before: remotePlayer.currentItem)
                        case .insertAfter:
                            remotePlayer.insertItems(from: assets, after: remotePlayer.currentItem)
                        case .append:
                            remotePlayer.appendItems(from: assets)
                        }
                    }
                    else {
                        let entries = medias.map(PlaylistEntry.init)
                        switch option {
                        case .prepend:
                            model.prependItems(from: entries)
                        case .insertBefore:
                            model.insertItemsBeforeCurrent(from: entries)
                        case .insertAfter:
                            model.insertItemsAfterCurrent(from: entries)
                        case .append:
                            model.appendItems(from: entries)
                        }
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
        if let remotePlayer = cast.player {
            RemotePlaybackView(player: remotePlayer)
        }
        else {
            LocalPlaybackView(model: model, player: model.player)
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
