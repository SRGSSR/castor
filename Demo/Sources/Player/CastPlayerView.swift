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
                MessageView(message: "Not connected", icon: .system("play.slash.fill"))
                    .overlay(alignment: .topTrailing) {
                        ProgressView()
                            .padding()
                            .opacity(cast.connectionState == .connecting ? 1 : 0)
                    }
            }
        }
        .animation(.default, value: cast.player)
        .onAppear {
            cast.update(configuration: .standard)
        }
    }
}

#Preview {
    CastPlayerView()
        .environmentObject(Cast())
}
