//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Castor
import SwiftUI

struct RemotePlayer: View {
    @ObservedObject var player: CastPlayer

    var body: some View {
        Rectangle()
            .fill(.primary.opacity(0.2))
            .aspectRatio(contentMode: .fit)
            .overlay {
                AsyncImage(url: player.currentItem?.metadata?.imageUrl()) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    EmptyView()
                }
            }
            .clipShape(.rect)
    }
}
