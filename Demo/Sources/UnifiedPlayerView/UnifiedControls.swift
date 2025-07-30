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
                RemoteUnifiedControls(player: remotePlayer)
            }
            else {
                LocalUnifiedControls(player: player)
            }
        }
    }
}

private struct RemoteUnifiedControls: View {
    @ObservedObject var player: CastPlayer

    var body: some View {
        ZStack {
            RemotePlaybackButton(player: player)
            RemotePlaybackSlider(player: player)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        }
    }
}

private struct LocalUnifiedControls: View {
    @ObservedObject var player: Player
    @StateObject private var visibilityTracker = VisibilityTracker()

    var body: some View {
        ZStack {
            LocalPlaybackButton(player: player)
            LocalPlaybackSlider(player: player)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        }
        .bind(visibilityTracker, to: player)
        .opacity(visibilityTracker.isUserInterfaceHidden ? 0 : 1)
        .contentShape(.rect)
        .onTapGesture(perform: visibilityTracker.toggle)
    }
}
