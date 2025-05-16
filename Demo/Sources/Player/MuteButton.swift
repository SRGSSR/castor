//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Castor
import SwiftUI

struct MuteButton: View {
    @EnvironmentObject var cast: Cast

    var body: some View {
        Button {
            cast.isMuted.toggle()
        } label: {
            Image(systemName: imageName)
        }
        .disabled(!cast.canAdjustVolume)
    }

    private var imageName: String {
        cast.isMuted ? "speaker.slash.fill" : "speaker.wave.3.fill"
    }
}
