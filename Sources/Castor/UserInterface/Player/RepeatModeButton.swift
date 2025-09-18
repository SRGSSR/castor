//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

struct RepeatModeButton: View {
    @ObservedObject var player: CastPlayer
    let style: ButtonStyle

    var body: some View {
        Button(action: toggleRepeatMode) {
            ZStack {
                switch style {
                case .large:
                    Label {
                        Text("Repeat", bundle: .module, comment: "Button to toggle between repeat modes")
                    } icon: {
                        Image(systemName: repeatModeImageName)
                    }
                    .fixedSize()
                case .compact:
                    Image(systemName: repeatModeImageName)
                }
                PlaylistToolbar.largestShape()
            }
            .frame(maxWidth: .infinity)
        }
        .disabled(!player.isActive)
    }

    private var repeatModeImageName: String {
        switch player.repeatMode {
        case .off:
            "repeat.circle"
        case .one:
            "repeat.1.circle.fill"
        case .all:
            "repeat.circle.fill"
        }
    }

    private func toggleRepeatMode() {
        switch player.repeatMode {
        case .off:
            player.repeatMode = .all
        case .one:
            player.repeatMode = .off
        case .all:
            player.repeatMode = .one
        }
    }
}
