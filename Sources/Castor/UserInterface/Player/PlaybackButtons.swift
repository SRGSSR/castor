//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

struct PlaybackButtons: View {
    @EnvironmentObject private var cast: Cast
    @ObservedObject var player: CastPlayer
    let layout: PlaybackButtonsLayout

    var body: some View {
        ZStack {
            largestShape()
            buttons()
        }
        .font(.system(size: 44))
        .disabled(!player.isActive)
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
                previousButton()
            case .skip:
                skipBackwardButton()
            }
        }
        .font(.system(size: 30))
    }

    private func forwardButton() -> some View {
        Group {
            switch layout {
            case .navigation:
                nextButton()
            case .skip:
                skipForwardButton()
            }
        }
        .font(.system(size: 30))
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
        Button(action: player.returnToPreviousItem) {
            Image(systemName: "backward.end.fill")
        }
        .accessibilityLabel(String(localized: "Previous", bundle: .module, comment: "Previous item button accessibility label"))
        .disabled(!player.canReturnToPreviousItem())
    }

    private func nextButton() -> some View {
        Button(action: player.advanceToNextItem) {
            Image(systemName: "forward.end.fill")
        }
        .accessibilityLabel(String(localized: "Next", bundle: .module, comment: "Next item button accessibility label"))
        .disabled(!player.canAdvanceToNextItem())
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
