//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Castor
import SwiftUI

struct SettingsMenu: View {
    let player: CastPlayer

    var body: some View {
        Menu {
            player.standardSettingsMenu()
        } label: {
            Image(systemName: "gearshape.fill")
                .font(.system(size: 20))
                .tint(.accent)
        }
        .menuOrder(.fixed)
    }
}
