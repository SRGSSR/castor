//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

struct LiveLabel: View {
    @StateObject private var progressTracker = CastProgressTracker(interval: .init(value: 1, timescale: 1))
    @ObservedObject var player: CastPlayer

    private var canSkipToLive: Bool {
        player.canSkipToDefault()
    }

    private var liveButtonColor: Color {
        canSkipToLive && player.streamType == .live ? .gray : .red
    }

    var body: some View {
        Group {
            if player.streamType == .live {
                Text("LIVE")
                    .font(.footnote)
                    .padding(.horizontal, 7)
                    .background(liveButtonColor)
                    .foregroundColor(.white)
                    .clipShape(.capsule)
            }
        }
        .bind(progressTracker, to: player)
    }
}
