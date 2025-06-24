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
    @EnvironmentObject private var cast: Cast
    @Environment(\.dismiss) private var dismiss
    let media: Media

    var body: some View {
        NavigationStack {
            VideoPlayer(player: model.player)
                .ignoresSafeArea()
                .onAppear {
                    model.media = media
                    model.cast = cast
                    model.dismiss = dismiss
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
