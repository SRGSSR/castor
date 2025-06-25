//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVKit
import Castor
import SwiftUI

struct PlayerView: View {
    @State private var model = PlayerViewModel()
    let media: Media

    var body: some View {
        NavigationStack {
            VideoPlayer(player: model.player)
                .ignoresSafeArea()
                .onAppear {
                    model.play()
                }
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        CastButton()
                    }
                }
        }
    }
}
