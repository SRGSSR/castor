//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import PillarboxPlayer
import SwiftUI

struct LocalPlayer: View {
    let player: Player

    var body: some View {
        VideoView(player: player)
            .onAppear(perform: player.play)
    }
}
