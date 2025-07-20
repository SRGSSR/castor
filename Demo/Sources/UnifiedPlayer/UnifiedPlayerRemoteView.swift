//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Castor
import SwiftUI

private struct _Slider: View {
    @ObservedObject var player: CastPlayer
    @State private var progressTracker = CastProgressTracker(interval: .init(value: 1, timescale: 1))

    var body: some View {
        Slider(progressTracker: progressTracker)
            .bind(progressTracker, to: player)
    }
}

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
            ControlsView(unifiedPlayer: player, slider: AnyView(_Slider(player: player)))
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
