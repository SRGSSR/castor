//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

struct PreviousItemButton: View {
    @ObservedObject var player: CastPlayer

    var body: some View {
        Button(action: player.returnToPreviousItem) {
            Image(systemName: "backward.end.fill")
        }
        .accessibilityLabel(accessibilityLabel)
        .disabled(!player.canReturnToPreviousItem())
    }
}

private extension PreviousItemButton {
    var accessibilityLabel: LocalizedStringResource {
        LocalizedStringResource("Previous", bundle: .module, comment: "Previous item button accessibility label")
    }
}
