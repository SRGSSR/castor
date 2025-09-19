//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

struct NextItemButton: View {
    @ObservedObject var player: CastPlayer

    var body: some View {
        Button(action: player.advanceToNextItem) {
            Image(systemName: "forward.end.fill")
        }
        .accessibilityLabel(accessibilityLabel)
        .disabled(!player.canAdvanceToNextItem())
    }
}

private extension NextItemButton {
    var accessibilityLabel: String {
        String(localized: "Next", bundle: .module, comment: "Next item button accessibility label")
    }
}
