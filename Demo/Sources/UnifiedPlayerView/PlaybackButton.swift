//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Castor
import PillarboxPlayer
import SwiftUI

struct LocalPlaybackButton: View {
    @ObservedObject var player: Player

    var body: some View {
        PlaybackButton(shouldPlay: player.shouldPlay, perform: player.togglePlayPause)
    }
}

struct RemotePlaybackButton: View {
    @ObservedObject var player: CastPlayer

    var body: some View {
        PlaybackButton(shouldPlay: player.shouldPlay, perform: player.togglePlayPause)
    }
}

private struct PlaybackButton: View {
    let shouldPlay: Bool
    let action: () -> Void

    var body: some View {
        Button {
            action()
        } label: {
            Image(systemName: shouldPlay ? "pause" : "play")
        }
    }

    init(shouldPlay: Bool, perform action: @escaping () -> Void) {
        self.shouldPlay = shouldPlay
        self.action = action
    }
}
