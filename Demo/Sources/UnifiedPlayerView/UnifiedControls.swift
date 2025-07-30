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
        Group {
            if let remotePlayer = cast.player {
                RemoteControls(player: remotePlayer)
            }
            else {
                LocalControls(player: player)
            }
        }
    }
}

private struct RemoteControls: View {
    @ObservedObject var player: CastPlayer
    @StateObject private var progressTracker = CastProgressTracker(interval: .init(value: 1, timescale: 1))

    var body: some View {
        ZStack {
            PlaybackButton(shouldPlay: player.shouldPlay, perform: player.togglePlayPause)
            Slider(progressTracker: progressTracker)
                .bind(progressTracker, to: player)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        }
    }
}

private struct LocalControls: View {
    @ObservedObject var player: Player
    @StateObject private var visibilityTracker = VisibilityTracker()
    @StateObject private var progressTracker = ProgressTracker(interval: .init(value: 1, timescale: 1))

    var body: some View {
        ZStack {
            PlaybackButton(shouldPlay: player.shouldPlay, perform: player.togglePlayPause)
            Slider(progressTracker: progressTracker)
                .bind(progressTracker, to: player)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        }
        .bind(visibilityTracker, to: player)
        .opacity(visibilityTracker.isUserInterfaceHidden ? 0 : 1)
        .contentShape(.rect)
        .onTapGesture(perform: visibilityTracker.toggle)
    }
}
