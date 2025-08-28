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
                Text(String(localized: "Live", comment: "Short label associated with live content").uppercased())
                    .font(.footnote)
                    .padding(.horizontal, 7)
                    .background(liveButtonColor)
                    .foregroundStyle(.white)
                    .clipShape(.capsule)
            }
        }
        .bind(progressTracker, to: player)
    }
}
