//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Castor
import CoreMedia
import SwiftUI

private struct ItemCell: View {
    @ObservedObject var item: CastPlayerItem

    var body: some View {
        HStack(spacing: 30) {
            Text(title)
            Spacer()
            disclosureImage()
        }
        .onAppear(perform: item.fetch)
    }

    private var title: String {
        guard item.isFetched else { return "..." }
        return item.asset?.metadata?.title ?? "Untitled"
    }

    private func disclosureImage() -> some View {
        Image(systemName: "line.3.horizontal")
            .foregroundStyle(.secondary)
    }
}

private struct RemoteTimeBar: View {
    let player: CastPlayer

    @StateObject private var progressTracker = CastProgressTracker(interval: .init(value: 1, timescale: 10))

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
                .shadow(color: .init(white: 0.2, opacity: 0.8), radius: 15)
        }
    }
}

struct RemotePlaybackView: View {
    @ObservedObject var player: CastPlayer

    var body: some View {
        ZStack {
            if !player.items.isEmpty {
                VStack(spacing: 0) {
                    mainView()
                    playlistView()
                }
            }
            else {
                Text("No content")
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func mainView() -> some View {
        ZStack {
            artwork()
            controls()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    @ViewBuilder
    private func playbackButton() -> some View {
        if !player.isBusy {
            PlaybackButton(shouldPlay: player.shouldPlay, perform: player.togglePlayPause)
        }
        else {
            ProgressView()
                .tint(.white)
        }
    }

    private func controls() -> some View {
        ZStack {
            Color(white: 0, opacity: 0.4)
            playbackButton()
            RemoteTimeBar(player: player)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                .padding()
        }
    }

    private func playlistView() -> some View {
        List($player.items, id: \.self, editActions: .all, selection: $player.currentItem) { $item in
            ItemCell(item: item)
        }
    }

    private func artwork() -> some View {
        AsyncImage(url: player.currentAsset?.metadata?.imageUrl()) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fit)
        } placeholder: {
            EmptyView()
        }
    }
}
