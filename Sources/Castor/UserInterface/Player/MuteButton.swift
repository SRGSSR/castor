//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

struct MuteButton: View {
    @ObservedObject var cast: Cast

    var body: some View {
        Button {
            cast.isMuted.toggle()
        } label: {
            MuteIcon(cast: cast)
        }
        .disabled(!cast.canMute)
    }
}
