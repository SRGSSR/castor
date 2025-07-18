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
    @StateObject private var localPlayer = Player()
    private var remotePlayer: CastPlayer? {
        guard [.connected, .connecting].contains(cast.connectionState) else { return nil }
        return cast.player
    }

    @StateObject private var viewModel = UnifiedPlayerViewModel()

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
        .supportsCast(cast, with: viewModel)
    }

    @ViewBuilder
    private func backgroundLayer() -> some View {
        if let remotePlayer {
            RemotePlayer(player: remotePlayer)
        }
        else {
            LocalPlayer(player: localPlayer)
        }
    }

    @ViewBuilder
    private func foregroundLayer() -> some View {
        if let remotePlayer {
            ControlsView(unifiedPlayer: remotePlayer)
        }
        else {
            ControlsView(unifiedPlayer: localPlayer)
        }
    }
}

#Preview {
    RootView()
}
