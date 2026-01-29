//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

struct ControlsView: View {
    let player: CastPlayer
    @Binding var isPlaylistPresented: Bool
    let cast: Cast

    @Environment(\.verticalSizeClass) private var verticalSizeClass

    private var layout: PlaybackButtonsLayout {
        (isPlaylistPresented || verticalSizeClass == .compact) ? .navigation : .skip
    }

    var body: some View {
        VStack {
            SliderView(player: player)
            VStack(spacing: 50) {
                PlaybackButtons(player: player, layout: layout, cast: cast)
                SettingsButtons(player: player, isPlaylistPresented: $isPlaylistPresented, cast: cast)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(.background)
    }
}
