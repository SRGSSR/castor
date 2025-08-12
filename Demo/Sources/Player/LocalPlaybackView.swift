//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import CoreMedia
import PillarboxPlayer
import SwiftUI

private struct LocalTimeBar: View {
    let player: Player

    @StateObject private var progressTracker = ProgressTracker(interval: .init(value: 1, timescale: 10))

    private var formattedElapsedTime: String? {
        CMTime.formattedTime((progressTracker.time - progressTracker.timeRange.start), duration: progressTracker.timeRange.duration)
    }

    private var formattedTotalTime: String? {
        CMTime.formattedTime(progressTracker.timeRange.duration, duration: progressTracker.timeRange.duration)
    }

    var body: some View {
        Slider(progressTracker: progressTracker) {
            Text("Progress")
        } minimumValueLabel: {
            label(withText: formattedElapsedTime)
        } maximumValueLabel: {
            label(withText: formattedTotalTime)
        }
        .opacity(progressTracker.isProgressAvailable ? 1 : 0)
        .bind(progressTracker, to: player)
    }

    @ViewBuilder
    private func label(withText text: String?) -> some View {
        if let text {
            Text(text)
                .font(.caption)
                .monospacedDigit()
                .foregroundColor(.white)
        }
    }
}

private struct LocalPaybackButton: View {
    @ObservedObject var player: Player

    @State private var isBusy = false

    var body: some View {
        ZStack {
            if !isBusy {
                PlaybackButton(shouldPlay: player.shouldPlay, perform: player.togglePlayPause)
            }
            else {
                ProgressView()
                    .tint(.white)
            }
        }
        .onReceive(player: player, assign: \.isBusy, to: $isBusy)
    }
}

struct LocalPlaybackView: View {
    @ObservedObject var model: PlayerViewModel
    @ObservedObject var player: Player

    @StateObject private var visibilityTracker = VisibilityTracker()

    var body: some View {
        ZStack {
            if let error = player.error {
                Text(error.localizedDescription)
            }
            else if !player.items.isEmpty {
                VStack(spacing: 0) {
                    mainView()
                    playlistView()
                }
            }
            else {
                Text("No content")
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
        .accessibilityAddTraits(.isButton)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func controls() -> some View {
        ZStack {
            Color(white: 0, opacity: 0.4)
            LocalPaybackButton(player: player)
            LocalTimeBar(player: player)
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
