//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Castor
import SwiftUI

struct CastPlayerView: View {
    @EnvironmentObject private var cast: Cast

    var body: some View {
        VStack {
            if let player = cast.player {
                ControlsView(player: player, device: cast.currentDevice)
                PlaylistView(queue: player.queue)
            }
            else {
                ContentUnavailableView("Not connected", systemImage: "wifi.slash")
                    .overlay(alignment: .topTrailing) {
                        ProgressView()
                            .padding()
                            .opacity(cast.connectionState == .connecting ? 1 : 0)
                    }
            }
        }
        .animation(.default, value: cast.player)
    }
}

#Preview {
    CastPlayerView()
        .environmentObject(Cast())
}
