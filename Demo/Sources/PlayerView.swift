//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVKit
import Castor
import PillarboxPlayer
import SwiftUI

struct PlayerView: View {
    let content: PlayerContent?

    @State private var model = PlayerViewModel()
    @EnvironmentObject private var cast: Cast

    var body: some View {
        NavigationStack {
            SystemVideoView(player: model.player)
                .ignoresSafeArea()
                .onAppear(perform: play)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        CastButton(cast: cast)
                    }
                }
                .makeCastable(model, with: cast)
        }
    }

    private func play() {
        model.content = content
        model.play()
    }
}

// TODO: Remove this preview!
#Preview {
    CastButton(cast: .init())
}
