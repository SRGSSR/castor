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

    var body: some View {
        ZStack {
            if let remotePlayer = cast.player {
                RemoteControls(player: remotePlayer)
            }
            else {
                LocalPlayerView()
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                CastButton(cast: cast)
            }
        }
    }
}

struct RemotePlayerView: View {
    @ObservedObject var player: CastPlayer

    var body: some View {
        ZStack {
            Image(systemName: "star.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 200)
            RemoteControls(player: player)
        }
    }
}


struct LocalPlayerView: View {
    @StateObject private var player = Player(
        item: .simple(
            url: URL(
                string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_4x3/bipbop_4x3_variant.m3u8"
            )!
        )
    )

    var body: some View {
        ZStack {
            VideoView(player: player)
            LocalControls(player: player)
        }
    }
}
