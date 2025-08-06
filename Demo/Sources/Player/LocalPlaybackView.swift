//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import PillarboxPlayer
import SwiftUI

struct LocalPlaybackView: View {
    let model: PlayerViewModel
    @ObservedObject var player: Player

    var body: some View {
        ZStack {
            if let error = player.error {
                Text(error.localizedDescription)
            }
            else {
                VStack(spacing: 0) {
                    mainView()
                    playlistView()
                }
            }
        }
        .animation(.default, value: player.mediaType)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func mainView() -> some View {
        ZStack {
            if player.mediaType == .video {
                VideoView(player: player)
                    .background(.black)
            }
            else {
                artwork()
            }
            PlaybackButton(shouldPlay: player.shouldPlay, perform: player.togglePlayPause)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func playlistView() -> some View {
        List($player.items, id: \.self, editActions: .all, selection: $player.currentItem) { $item in
            if let index = player.items.firstIndex(of: item), let media = model.medias[safeIndex: index] {
                Text(media.title)
            }
        }
    }

    private func artwork() -> some View {
        LazyImage(source: player.metadata.imageSource) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fit)
        }
    }
}
