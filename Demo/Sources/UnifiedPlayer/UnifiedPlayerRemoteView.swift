//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Castor
import SwiftUI

struct UnifiedPlayerRemoteView: View {
    @ObservedObject var player: CastPlayer

    var body: some View {
        VStack {
            playback()
            playlist()
        }
    }

    private func playback() -> some View {
        ZStack {
            RemotePlayer(player: player)
            ControlsView(unifiedPlayer: player)
        }
    }

    private func playlist() -> some View {
        List($player.items, id: \.self, editActions: .all, selection: $player.currentItem) { $item in
            Text(item.metadata?.title ?? "Untitled")
                .onAppear(perform: item.fetch)
                .redacted(reason: item.metadata?.title == nil ? .placeholder : .init())
        }
    }
}
