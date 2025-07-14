//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

struct ControlsView: View {
    let player: CastPlayer
    @Binding var isPlaylistPresented: Bool

    var body: some View {
        VStack {
            SliderView(player: player)
            PlaybackButtons(player: player)
            SettingsButtons(player: player, isPlaylistPresented: $isPlaylistPresented)
        }
        .frame(maxWidth: .infinity)
        .background(.background)
    }
}
