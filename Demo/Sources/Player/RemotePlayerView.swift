//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Castor
import SwiftUI

struct RemotePlayerView: View {
    @EnvironmentObject private var cast: Cast

    @State private var isSelectionPresented = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            CastPlayerView(cast: cast)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        closeButton()
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        addButton()
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
                }
            }
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
