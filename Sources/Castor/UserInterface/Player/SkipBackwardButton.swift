//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

struct SkipBackwardButton: View {
    let player: CastPlayer
    let interval: TimeInterval

    @ObservedObject var progressTracker: CastProgressTracker

    var body: some View {
        Button(action: player.skipBackward) {
            Image.goBackward(withInterval: interval)
        }
        .accessibilityLabel(accessibilityLabel)
        .disabled(!player.canSkipBackward())
    }
}

private extension SkipBackwardButton {
    var accessibilityLabel: String {
        String(
            localized: "Go backward \(Int(interval)) seconds",
            bundle: .module,
            comment: "Skip backward button accessibility label (number of seconds as wildcards)"
        )
    }
}
