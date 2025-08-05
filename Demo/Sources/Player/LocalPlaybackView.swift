//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import PillarboxPlayer
import SwiftUI

struct LocalPlaybackView: View {
    @ObservedObject var player: Player

    var body: some View {
        ZStack {
            if let error = player.error {
                Text(error.localizedDescription)
            }
            else {
                if player.mediaType == .video {
                    VideoView(player: player)
                        .background(.black)
                }
                else {
                    artwork()
                }
                PlaybackButton(shouldPlay: player.shouldPlay, perform: player.togglePlayPause)
            }
        }
        .animation(.default, value: player.mediaType)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func artwork() -> some View {
        LazyImage(source: player.metadata.imageSource) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fit)
        }
    }
}
