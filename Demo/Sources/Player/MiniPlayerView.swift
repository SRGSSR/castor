//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Castor
import SwiftUI

struct MiniPlayerView: View {
    let cast: Cast
    @EnvironmentObject private var router: Router

    var body: some View {
        CastMiniPlayerView(cast: cast)
            .padding(.horizontal)
            .padding(.vertical, 8)
            .accessibilityAddTraits(.isButton)
            .onTapGesture {
                router.presented = .expandedPlayer
            }
    }
}
