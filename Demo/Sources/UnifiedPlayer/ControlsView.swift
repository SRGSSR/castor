//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

struct ControlsView<AnyPlayer>: View where AnyPlayer: UnifiedPlayer {
    @ObservedObject var unifiedPlayer: AnyPlayer
    let slider: AnyView

    var body: some View {
        ZStack {
            playbackButton()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .overlay(alignment: .bottom) {
            slider
        }
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
