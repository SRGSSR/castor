//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

struct SettingsButtons: View {
    @EnvironmentObject private var cast: Cast
    let player: CastPlayer
    @Binding var isPlaylistPresented: Bool
    @Environment(\.verticalSizeClass) private var verticalSizeClass

    var body: some View {
        HStack(spacing: 50) {
            CastButton(cast: cast)
            playlistButton()
            SettingsMenu(player: player)
            MuteButton(cast: cast)
        }
        .font(.system(size: 22))
    }

    @ViewBuilder
    private func playlistButton() -> some View {
        if verticalSizeClass == .regular {
            Button {
                isPlaylistPresented.toggle()
            } label: {
                Image(systemName: isPlaylistPresented ? "list.bullet.circle.fill" : "list.bullet.circle")
            }
        }
    }
}
