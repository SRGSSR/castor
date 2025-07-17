//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

struct PlaybackButton: View {
    @ObservedObject var player: CastPlayer

    private var imageName: String {
        player.shouldPlay ? "pause.fill" : "play.fill"
    }

    var body: some View {
        Button(action: player.togglePlayPause) {
            ZStack {
                largestShape()
                Image(systemName: imageName)
            }
        }
    }

    private func largestShape() -> some View {
        // https://stackoverflow.com/questions/78766259/sf-symbol-replace-animation-size-is-off
        ZStack {
            Image(systemName: "play.fill")
            Image(systemName: "pause.fill")
        }
        .hidden()
    }
}
