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

    var body: some View {
        HStack(spacing: 50) {
            CastButton(cast: cast)
            playlistButton()
            SettingsMenu(player: player)
            MuteButton(cast: cast)
        }
        .font(.system(size: 22))
    }

    private func playlistButton() -> some View {
        Button {
            isPlaylistPresented.toggle()
        } label: {
            Image(systemName: isPlaylistPresented ? "list.bullet.circle.fill" : "list.bullet.circle")
        }
    }
}
