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
    @EnvironmentObject private var router: Router
    let media: Media

    var body: some View {
        NavigationStack {
            VideoPlayer(player: model.player)
                .ignoresSafeArea()
                .onAppear {
                    router.dataSource = model
                    model.media = media
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
