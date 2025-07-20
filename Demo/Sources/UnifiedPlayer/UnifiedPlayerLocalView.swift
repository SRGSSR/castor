//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import PillarboxPlayer
import SwiftUI

struct UnifiedPlayerLocalView: View {
    @ObservedObject var player: Player
    @ObservedObject var viewModel: UnifiedPlayerViewModel

    var body: some View {
        VStack {
            playback()
            playlist()
        }
    }

    private func playback() -> some View {
        ZStack {
            LocalPlayer(player: player)
            ControlsView(unifiedPlayer: player)
        }
    }

    private func playlist() -> some View {
        List($viewModel.localMedias, id: \.self, editActions: .all, selection: $viewModel.currentLocalMedia) { $localMedia in
            Text(localMedia.media.title)
        }
    }
}
