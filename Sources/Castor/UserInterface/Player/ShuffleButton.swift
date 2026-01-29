//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

struct ShuffleButton: View {
    @ObservedObject var player: CastPlayer
    let style: ButtonStyle

    private var label: LocalizedStringResource {
        LocalizedStringResource("Shuffle", bundle: .module, comment: "Shuffle button accessibility label")
    }

    var body: some View {
        Button {
            player.items.shuffle()
        } label: {
            ZStack {
                switch style {
                case .large:
                    Label {
                        Text(label)
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
        .accessibilityLabel(label)
        .disabled(player.items.isEmpty)
    }
}
