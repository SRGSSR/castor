//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Castor
import PillarboxPlayer
import SwiftUI

struct UnifiedVideoView: View {
    @EnvironmentObject private var cast: Cast
    @ObservedObject var player: Player

    var body: some View {
        if let remotePlayer = cast.player {
            Image(systemName: "star.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 200)
        }
        else {
            VideoView(player: player)
        }
    }
}
