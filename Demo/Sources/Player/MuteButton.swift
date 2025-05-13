//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Castor
import SwiftUI

struct MuteButton: View {
    @ObservedObject var player: CastPlayer

    var body: some View {
        Button {
            player.isMuted.toggle()
        } label: {
            Image(systemName: imageName)
        }
    }

    private var imageName: String {
        player.isMuted ? "speaker.slash.fill" : "speaker.wave.3.fill"
    }
}
