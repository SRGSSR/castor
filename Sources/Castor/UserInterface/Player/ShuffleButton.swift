//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

struct ShuffleButton: View {
    @ObservedObject var player: CastPlayer
    let style: ButtonStyle

    var body: some View {
        Button {
            player.items.shuffle()
        } label: {
            ZStack {
                switch style {
                case .large:
                    Label {
                        Text("Shuffle", bundle: .module, comment: "Button to shuffle a playlist")
                    } icon: {
                        Image(systemName: "shuffle")
                    }
                    .fixedSize()
                case .compact:
                    Image(systemName: "shuffle")
                }
                PlaylistToolbar.largestShape()
            }
            .frame(maxWidth: .infinity)
        }
        .disabled(player.items.isEmpty)
    }
}
