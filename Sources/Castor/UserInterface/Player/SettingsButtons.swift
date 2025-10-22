//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

struct SettingsButtons: View {
    @EnvironmentObject private var cast: Cast
    @ObservedObject var player: CastPlayer
    @Binding var isPlaylistPresented: Bool
    @Environment(\.verticalSizeClass) private var verticalSizeClass

    var body: some View {
        HStack(spacing: 30) {
            if verticalSizeClass == .regular {
                playlistButton()
                Spacer()
            }
            SettingsMenu(player: player)
            if let deviceManager = cast.currentDeviceManager {
                CastMuteButton(deviceManager: deviceManager)
            }
            CastButton(cast: cast)
        }
        .font(.system(size: 22))
        .padding(.horizontal, 30)
    }

    private func playlistButton() -> some View {
        PlaylistButton(isPlaylistPresented: $isPlaylistPresented)
            .disabled(player.items.isEmpty)
    }
}
