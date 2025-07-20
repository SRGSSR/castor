//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import PillarboxPlayer
import SwiftUI

private struct _Slider: View {
    @ObservedObject var player: Player
    @State private var progressTracker = ProgressTracker(interval: .init(value: 1, timescale: 1))

    var body: some View {
        Slider(progressTracker: progressTracker)
            .bind(progressTracker, to: player)
    }
}

struct UnifiedPlayerLocalView: View {
    @ObservedObject var player: Player
    @ObservedObject var viewModel: UnifiedPlayerViewModel

    var body: some View {
        VStack {
            playback()
            playlist()
        }
        .onDisappear(perform: player.pause)
    }

    private func playback() -> some View {
        ZStack {
            LocalPlayer(player: player)
            ControlsView(unifiedPlayer: player, slider: AnyView(_Slider(player: player)))
        }
    }

    private func playlist() -> some View {
        List($viewModel.medias, id: \.self, editActions: .all, selection: $viewModel.currentMedia) { $localMedia in
            Text(localMedia.title)
        }
    }
}
