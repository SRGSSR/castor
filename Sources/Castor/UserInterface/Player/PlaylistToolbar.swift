//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

struct PlaylistToolbar: View {
    let player: CastPlayer

    var body: some View {
        ViewThatFits {
            HStack {
                RepeatModeButton(player: player, style: .large)
                ShuffleButton(player: player, style: .large)
                TrashButton(player: player, style: .large)
            }
            HStack {
                RepeatModeButton(player: player, style: .compact)
                ShuffleButton(player: player, style: .compact)
                TrashButton(player: player, style: .compact)
            }
        }
        .buttonStyle(.bordered)
        .padding()
    }

    static func largestShape() -> some View {
        // https://stackoverflow.com/questions/78766259/sf-symbol-replace-animation-size-is-off
        ZStack {
            Image(systemName: "repeat.circle")
            Image(systemName: "shuffle")
            Image(systemName: "trash")
        }
        .hidden()
    }
}
