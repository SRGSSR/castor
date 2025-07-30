//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Castor
import PillarboxPlayer
import SwiftUI

struct UnifiedPlayerView: View {
    @EnvironmentObject private var cast: Cast
    @StateObject private var player = Player(
        item: .simple(
            url: URL(
                string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_4x3/bipbop_4x3_variant.m3u8"
            )!
        )
    )

    var body: some View {
        ZStack {
            UnifiedVideoView(player: player)
            UnifiedControls(player: player)
        }
    }
}
