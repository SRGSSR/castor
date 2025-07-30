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
        SkinedPlaybackButton(shouldPlay: player.shouldPlay, perform: player.togglePlayPause)
    }
}

struct RemotePlaybackButton: View {
    @ObservedObject var player: CastPlayer

    var body: some View {
        SkinedPlaybackButton(shouldPlay: player.shouldPlay, perform: player.togglePlayPause)
    }
}

private struct SkinedPlaybackButton: View {
    let shouldPlay: Bool
    let action: () -> Void

    var body: some View {
        Button {
            action()
        } label: {
            Image(systemName: shouldPlay ? "pause.fill" : "play.fill")
        }
        .font(.system(size: 44))
    }

    init(shouldPlay: Bool, perform action: @escaping () -> Void) {
        self.shouldPlay = shouldPlay
        self.action = action
    }
}

struct UnifiedPlaybackButton: View {
    @EnvironmentObject private var cast: Cast
    @ObservedObject var player: Player

    var body: some View {
        if let remotePlayer = cast.player {
            RemotePlaybackButton(player: remotePlayer)
        }
        else {
            LocalPlaybackButton(player: player)
        }
    }
}
