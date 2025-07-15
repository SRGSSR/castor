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

    var body: some View {
        if let player = cast.player {
            NavigationStack {
                CastPlayerView(cast: cast)
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            addButton()
                        }
                    }
                    .toolbarBackground(.background, for: .navigationBar)
            }
            .sheet(isPresented: $isSelectionPresented) {
                NavigationStack {
                    PlaylistSelectionView(player: player)
                }
            }
        }
    }

    func addButton() -> some View {
        Button {
            isSelectionPresented.toggle()
        } label: {
            Image(systemName: "plus")
        }
    }
}
