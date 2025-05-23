//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Castor
import SwiftUI

private struct MainView: View {
    @ObservedObject var player: CastPlayer
    let device: CastDevice?

    var body: some View {
        VStack {
            ControlsView(player: player, device: device)
            Slider(value: $player.playbackSpeed, in: player.playbackSpeedRange)
            PlaylistView(player: player, queue: player.queue)
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                stopButton()
            }
            ToolbarItem(placement: .topBarTrailing) {
                MuteButton()
            }
            ToolbarItem(placement: .topBarTrailing) {
                SettingsMenu(player: player)
            }
        }
    }

    private func stopButton() -> some View {
        Button {
            player.stop()
        } label: {
            Text("Stop")
        }
    }
}

struct CastPlayerView: View {
    @EnvironmentObject private var cast: Cast

    var body: some View {
        ZStack {
            if let player = cast.player {
                MainView(player: player, device: cast.currentDevice)
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
