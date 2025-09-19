//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

struct SettingsMenu: View {
    @ObservedObject var player: CastPlayer

    var body: some View {
        Menu {
            player.standardSettingsMenu()
        } label: {
            Image(systemName: "gearshape.fill")
        }
        .menuOrder(.fixed)
        .accessibilityLabel(accessibilityLabel)
        .disabled(!player.isActive)
    }
}

private extension SettingsMenu {
    var accessibilityLabel: String {
        String(localized: "Settings", bundle: .module, comment: "Settings button accessibility label")
    }
}
