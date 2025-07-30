//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Castor
import PillarboxPlayer
import SwiftUI

struct UnifiedControls: View {
    @EnvironmentObject private var cast: Cast
    @ObservedObject var player: Player

    var body: some View {
        ZStack {
            UnifiedPlaybackButton(player: player)
            UnifiedSlider(player: player)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        }
    }
}
