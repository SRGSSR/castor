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
        ZStack {
            backgroundLayer()
            foregroundLayer()
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                CastButton(cast: cast)
            }
        }
    }

    @ViewBuilder
    private func backgroundLayer() -> some View {
        if let player = cast.player, [.connected, .connecting].contains(cast.connectionState) {
            RemotePlayer(player: player)
        }
        else {
            LocalPlayer(player: player)
        }
    }

    @ViewBuilder
    private func foregroundLayer() -> some View {
        if let castPlayer = cast.player {
            ControlsView(unifiedPlayer: castPlayer)
        }
        else {
            ControlsView(unifiedPlayer: player)
        }
    }
}

#Preview {
    RootView()
}
