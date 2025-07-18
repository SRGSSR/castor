//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

struct ControlsView<AnyPlayer>: View where AnyPlayer: UnifiedPlayer {
    @ObservedObject var unifiedPlayer: AnyPlayer

    var body: some View {
        playbackButton()
    }

    private func playbackButton() -> some View {
        Button {
            unifiedPlayer.togglePlayPause()
        } label: {
            Image(systemName: unifiedPlayer.shouldPlay ? "pause.circle.fill" : "play.circle.fill")
                .font(.system(size: 44))
        }
    }
}
