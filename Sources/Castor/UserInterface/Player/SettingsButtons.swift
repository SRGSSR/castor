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
            MuteButton(cast: cast)
            CastButton(cast: cast)
        }
        .font(.system(size: 22))
        .padding(.horizontal, 30)
    }

    private func playlistButton() -> some View {
        Button {
            isPlaylistPresented.toggle()
        } label: {
            Image(systemName: isPlaylistPresented ? "list.bullet.circle.fill" : "list.bullet.circle")
        }
        .disabled(player.items.isEmpty)
    }
}
