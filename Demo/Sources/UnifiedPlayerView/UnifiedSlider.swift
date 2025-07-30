//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Castor
import PillarboxPlayer
import SwiftUI

private struct LocalPlaybackSlider: View {
    @ObservedObject var player: Player
    @StateObject private var progressTracker = ProgressTracker(interval: .init(value: 1, timescale: 1))

    var body: some View {
        Slider(progressTracker: progressTracker)
            .bind(progressTracker, to: player)
    }
}

private struct RemotePlaybackSlider: View {
    @ObservedObject var player: CastPlayer
    @StateObject private var progressTracker = CastProgressTracker(interval: .init(value: 1, timescale: 1))

    var body: some View {
        Slider(progressTracker: progressTracker)
            .bind(progressTracker, to: player)
    }
}

struct UnifiedSlider: View {
    @EnvironmentObject private var cast: Cast
    @ObservedObject var player: Player

    var body: some View {
        if let remotePlayer = cast.player {
            RemotePlaybackSlider(player: remotePlayer)
        }
        else {
            LocalPlaybackSlider(player: player)
        }
    }
}
