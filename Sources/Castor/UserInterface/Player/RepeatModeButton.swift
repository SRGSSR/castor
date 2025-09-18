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
        .accessibilityLabel(accessibilityLabel)
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

private extension RepeatModeButton {
    var accessibilityLabel: String {
        switch player.repeatMode {
        case .off:
            String(localized: "Repeat, Off", bundle: .module, comment: "Repeat off mode accessibility label")
        case .one:
            String(localized: "Repeat, One", bundle: .module, comment: "Repeat one mode accessibility label")
        case .all:
            String(localized: "Repeat, All", bundle: .module, comment: "Repeat all accessibility label")
        }
    }
}
