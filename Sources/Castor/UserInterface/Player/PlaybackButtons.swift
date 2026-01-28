//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

struct PlaybackButtons: View {
    @ObservedObject var player: CastPlayer
    let layout: PlaybackButtonsLayout
    let cast: Cast

    @StateObject private var progressTracker = CastProgressTracker(interval: .init(value: 1, timescale: 1))

    var body: some View {
        ZStack {
            largestShape()
            buttons()
        }
        .font(.system(size: 44))
        .disabled(!player.isActive)
        .bind(progressTracker, to: player)
    }

    private func buttons() -> some View {
        HStack(spacing: 40) {
            backwardButton()
            PlaybackButton(player: player)
            forwardButton()
        }
    }

    private func backwardButton() -> some View {
        Group {
            switch layout {
            case .navigation:
                PreviousItemButton(player: player)
            case .skip:
                SkipBackwardButton(
                    player: player,
                    interval: cast.configuration.backwardSkipInterval,
                    progressTracker: progressTracker
                )
            }
        }
        .font(.system(size: 30))
    }

    private func forwardButton() -> some View {
        Group {
            switch layout {
            case .navigation:
                NextItemButton(player: player)
            case .skip:
                SkipForwardButton(
                    player: player,
                    interval: cast.configuration.forwardSkipInterval,
                    progressTracker: progressTracker
                )
            }
        }
        .font(.system(size: 30))
    }

    private func largestShape() -> some View {
        // https://stackoverflow.com/questions/78766259/sf-symbol-replace-animation-size-is-off
        ZStack {
            Image(systemName: "backward.end.fill")
            Image(systemName: "forward.end.fill")
            Image(systemName: "gobackward.minus")
            Image(systemName: "gobackward.plus")
        }
        .hidden()
    }
}
