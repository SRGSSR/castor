//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Castor
import SwiftUI

struct LocalPlayerView: View {
    let media: Media

    @EnvironmentObject private var cast: Cast
    @StateObject private var model = PlayerViewModel()

    @State private var isSelectionPresented = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            LocalPlaybackView(model: model, player: model.player)
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
                    let entries = medias.map { PlaylistEntry(media: $0) }
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
        .onAppear {
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
