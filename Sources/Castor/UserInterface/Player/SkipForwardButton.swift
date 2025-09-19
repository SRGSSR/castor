//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

struct SkipForwardButton: View {
    let player: CastPlayer
    let interval: TimeInterval

    @ObservedObject var progressTracker: CastProgressTracker

    var body: some View {
        Button(action: player.skipForward) {
            Image.goForward(withInterval: interval)
        }
        .accessibilityLabel(accessibilityLabel)
        .disabled(!player.canSkipForward())
    }
}

private extension SkipForwardButton {
    var accessibilityLabel: String {
        String(
            localized: "Go forward \(Int(interval)) seconds",
            bundle: .module,
            comment: "Skip forward button accessibility label (number of seconds as wildcards)"
        )
    }
}
