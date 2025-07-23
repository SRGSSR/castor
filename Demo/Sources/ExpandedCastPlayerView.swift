//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Castor
import SwiftUI

struct ExpandedCastPlayerView: View {
    @ObservedObject var cast: Cast
    @State private var isSelectionPresented = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack {
                CastPlayerView(cast: cast)
                if let player = cast.player {
                    TestView(player: player)
                }
            }
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
                PlaylistSelectionView(player: cast.player)
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

struct TestView: View {
    @ObservedObject var player: CastPlayer

    private var myMetadata: MyMetadata? {
        player.data(ofType: MyMetadata.self)
    }

    var body: some View {
        Text(myMetadata?.title ?? "")
    }
}
