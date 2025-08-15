//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Castor
import CoreMedia
import SwiftUI

private struct RemoteItemCell: View {
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
                .foregroundStyle(.white)
        }
    }
}

struct RemotePlaybackView: View {
    @ObservedObject var player: CastPlayer

    var body: some View {
        VStack(spacing: 0) {
            mainView()
            playlist()
        }
        .animation(.default, value: player.items)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func mainView() -> some View {
        ZStack {
            artwork()
            controls()
        }
        .aspectRatio(16 / 9, contentMode: .fit)
        .frame(maxWidth: .infinity)
        .background(.black)
    }

    @ViewBuilder
    private func playbackButton() -> some View {
        if player.isBusy {
            ProgressView()
        }
        else {
            Button(action: player.togglePlayPause) {
                Image(systemName: player.shouldPlay ? "pause.fill" : "play.fill")
            }
            .font(.system(size: 44))
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
        .tint(.white)
        .foregroundStyle(.white)
        .disabled(!player.isActive)
    }

    private func playlist() -> some View {
        List($player.items, id: \.self, editActions: .all, selection: $player.currentItem) { $item in
            RemoteItemCell(item: item)
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
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
