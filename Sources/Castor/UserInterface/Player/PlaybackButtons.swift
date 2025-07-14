//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

struct PlaybackButtons: View {
    @EnvironmentObject private var cast: Cast
    @ObservedObject var player: CastPlayer

    var body: some View {
        ZStack {
            largestShape()
            buttons()
        }
        .font(.system(size: 44))
        .disabled(!player.isActive)
    }

    private func buttons() -> some View {
        HStack(spacing: 50) {
            backwardButton()
            PlaybackButton(player: player)
            stopButton()
            forwardButton()
        }
    }

    private func stopButton() -> some View {
        Button {
            player.stop()
        } label: {
            Image(systemName: "stop.fill")
        }
    }

    @ViewBuilder
    private func backwardButton() -> some View {
        if player.items.count <= 1 {
            skipBackwardButton()
        }
        else {
            previousButton()
        }
    }

    @ViewBuilder
    private func forwardButton() -> some View {
        if player.items.count <= 1 {
            skipForwardButton()
        }
        else {
            nextButton()
        }
    }

    private func skipBackwardButton() -> some View {
        Button(action: player.skipBackward) {
            Image.goBackward(withInterval: cast.configuration.backwardSkipInterval)
        }
        .disabled(!player.canSkipBackward())
    }

    private func skipForwardButton() -> some View {
        Button(action: player.skipForward) {
            Image.goForward(withInterval: cast.configuration.forwardSkipInterval)
        }
        .disabled(!player.canSkipForward())
    }

    private func previousButton() -> some View {
        Button(action: player.returnToPrevious) {
            Image(systemName: "backward.fill")
        }
        .disabled(!player.canReturnToPrevious())
    }

    private func nextButton() -> some View {
        Button(action: player.advanceToNext) {
            Image(systemName: "forward.fill")
        }
        .disabled(!player.canAdvanceToNext())
    }

    private func largestShape() -> some View {
        // https://stackoverflow.com/questions/78766259/sf-symbol-replace-animation-size-is-off
        ZStack {
            Image(systemName: "backward.fill")
            Image(systemName: "forward.fill")
            Image(systemName: "gobackward.minus")
            Image(systemName: "gobackward.plus")
        }
        .hidden()
    }
}
