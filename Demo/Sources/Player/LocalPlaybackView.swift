//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import PillarboxPlayer
import SwiftUI

struct LocalPlaybackView: View {
    @ObservedObject var model: PlayerViewModel
    @ObservedObject var player: Player

    @StateObject private var visibilityTracker = VisibilityTracker()

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
        .bind(visibilityTracker, to: player)
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
            controls()
        }
        .onTapGesture(perform: visibilityTracker.toggle)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func controls() -> some View {
        ZStack {
            Color(white: 0, opacity: 0.4)
            PlaybackButton(shouldPlay: player.shouldPlay, perform: player.togglePlayPause)
            TimeBar(player: player)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                .padding()
        }
        .opacity(visibilityTracker.isUserInterfaceHidden ? 0 : 1)
        .animation(.default, value: visibilityTracker.isUserInterfaceHidden)
    }

    private func playlistView() -> some View {
        List($model.entries, id: \.self, editActions: .all, selection: $model.currentEntry) { $entry in
            Text(entry.media.title)
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

private struct TimeBar: View {
    let player: Player

    @StateObject private var progressTracker = ProgressTracker(interval: .init(value: 1, timescale: 10))

    var body: some View {
        Slider(progressTracker: progressTracker)
            .opacity(progressTracker.isProgressAvailable ? 1 : 0)
            .bind(progressTracker, to: player)
    }
}
