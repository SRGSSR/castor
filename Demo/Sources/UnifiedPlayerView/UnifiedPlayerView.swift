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
    @StateObject private var player = Player()

    var body: some View {
        if let remotePlayer = cast.player {
            RemotePlaybackButton(player: remotePlayer)
        }
        else {
            LocalPlaybackButton(player: player)
        }
    }
}
