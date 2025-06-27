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
    @EnvironmentObject private var cast: Cast
    let medias: [Media]
    let startIndex: Int
    let startTime: CMTime

    var body: some View {
        NavigationStack {
            SystemVideoView(player: model.player)
                .ignoresSafeArea()
                .onAppear(perform: play)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        CastButton()
                    }
                }
                .makeCastable(model, with: cast)
        }
    }

    private func play() {
        model.setMedias(medias, startIndex: startIndex, startTime: startTime)
        model.play()
    }
}
