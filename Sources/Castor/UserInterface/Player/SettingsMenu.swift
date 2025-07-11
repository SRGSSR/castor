//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Castor
import SwiftUI

struct SettingsMenu: View {
    @ObservedObject var player: CastPlayer

    var body: some View {
        Menu {
            player.standardSettingsMenu()
        } label: {
            Image(systemName: "gearshape.fill")
                .font(.system(size: 20))
        }
        .menuOrder(.fixed)
        .disabled(!player.isActive)
    }
}
