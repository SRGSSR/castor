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
    @State private var model = PlayerViewModel()
    @EnvironmentObject private var router: Router
    @EnvironmentObject private var cast: Cast
    let medias: [Media]

    var body: some View {
        NavigationStack {
            SystemVideoView(player: model.player)
                .ignoresSafeArea()
                .enableCastPlaybackSwitching(cast, using: router, and: model)
                .onAppear(perform: play)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        CastButton()
                    }
                }
        }
    }

    private func play() {
        model.medias = medias
        model.play()
    }
}
