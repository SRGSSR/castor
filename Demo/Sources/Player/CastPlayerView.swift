//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Castor
import SwiftUI

private struct TimeSlider: View {
    @ObservedObject var player: CastPlayer

    var body: some View {
        Slider(value: player.playbackSpeed, in: player.playbackSpeedRange)
    }
}

struct CastPlayerView: View {
    @EnvironmentObject private var cast: Cast

    var body: some View {
        VStack {
            if let player = cast.player {
                ControlsView(player: player, device: cast.currentDevice)
                TimeSlider(player: player)
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
    }
}

#Preview {
    CastPlayerView()
        .environmentObject(Cast())
}
