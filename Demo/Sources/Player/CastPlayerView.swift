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
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                stopButton()
            }
            ToolbarItem(placement: .topBarTrailing) {
                settingsMenu()
            }
        }
    }

    @ViewBuilder
    private func stopButton() -> some View {
        if let player = cast.player {
            Button {
                player.stop()
            } label: {
                Text("Stop")
            }
        }
    }

    @ViewBuilder
    private func settingsMenu() -> some View {
        if let player = cast.player {
            SettingsMenu(player: player)
        }
    }
}

#Preview {
    CastPlayerView()
        .environmentObject(Cast())
}
