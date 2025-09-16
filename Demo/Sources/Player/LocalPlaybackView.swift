//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import CoreMedia
import PillarboxPlayer
import SwiftUI

private struct LocalItemCell: View {
    let media: Media

    var body: some View {
        HStack(spacing: 30) {
            Text(media.title)
            Spacer()
            disclosureImage()
        }
    }

    private func disclosureImage() -> some View {
        Image(systemName: "line.3.horizontal")
            .foregroundStyle(.secondary)
    }
}

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
        .tint(.white)
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

private struct LocalPaybackButton: View {
    @ObservedObject var player: Player
    @State private var isBusy = false

    private var imageName: String {
        if player.canReplay() {
            return "arrow.trianglehead.counterclockwise"
        }
        else if player.shouldPlay {
            return "pause.fill"
        }
        else {
            return "play.fill"
        }
    }

    var body: some View {
        ZStack {
            if isBusy {
                ProgressView()
                    .tint(.white)
            }
            else {
                Button(action: togglePlayPause) {
                    Image(systemName: imageName)
                }
                .font(.system(size: 44))
                .foregroundStyle(.white)
            }
        }
        .onReceive(player: player, assign: \.isBusy, to: $isBusy)
    }

    private func togglePlayPause() {
        if player.canReplay() {
            player.replay()
        }
        else {
            player.togglePlayPause()
        }
    }
}

private struct LocalErrorView: View {
    let error: Error
    let action: () -> Void

    var body: some View {
        VStack {
            Text(error.localizedDescription)
                .multilineTextAlignment(.center)
                .foregroundStyle(.white)
            Text("Tap to retry")
                .font(.subheadline)
                .foregroundStyle(.gray)
        }
        .padding()
        .onTapGesture(perform: action)
        .accessibilityAddTraits(.isButton)
    }
}

struct LocalPlaybackView: View {
    @ObservedObject var model: PlayerViewModel
    @ObservedObject var player: Player
    @Binding var isUserInterfaceHidden: Bool

    @StateObject private var visibilityTracker = VisibilityTracker()

    var areControlsHidden: Bool {
        visibilityTracker.isUserInterfaceHidden || player.error != nil || player.items.isEmpty
    }

    var body: some View {
        VStack(spacing: 0) {
            mainView()
            playlist()
        }
        .onChange(of: visibilityTracker.isUserInterfaceHidden) { newValue in
            isUserInterfaceHidden = newValue
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .bind(visibilityTracker, to: player)
    }

    private func mainView() -> some View {
        ZStack {
            if let error = player.error {
                LocalErrorView(error: error, action: player.replay)
            }
            else if player.items.isEmpty {
                Text("No content")
                    .padding()
                    .foregroundStyle(.white)
            }
            else {
                playerView()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .aspectRatio(16 / 9, contentMode: .fit)
        .frame(maxWidth: .infinity)
        .background(.black)
        .overlay(content: controls)
        .onTapGesture(perform: visibilityTracker.toggle)
        .accessibilityAddTraits(.isButton)
    }

    private func playerView() -> some View {
        ZStack {
            artwork()
            VideoView(player: player)
        }
    }

    @ViewBuilder
    private func controls() -> some View {
        ZStack {
            LocalPaybackButton(player: player)
            bottomBar()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.black.opacity(0.4))
        .opacity(areControlsHidden ? 0 : 1)
        .animation(.default, value: visibilityTracker.isUserInterfaceHidden)
        .onTapGesture(perform: visibilityTracker.toggle)
        .accessibilityAddTraits(.isButton)
    }

    private func bottomBar() -> some View {
        HStack {
            LocalTimeBar(player: player)
            settingsButton()
        }
        .padding()
        .frame(maxHeight: .infinity, alignment: .bottom)
    }

    private func settingsButton() -> some View {
        Menu {
            player.standardSettingsMenu()
        } label: {
            Image(systemName: "ellipsis.circle")
                .font(.system(size: 20))
                .tint(.white)
        }
        .menuOrder(.fixed)
    }

    private func playlist() -> some View {
        List($model.entries, id: \.self, editActions: .all, selection: $model.currentEntry) { $entry in
            LocalItemCell(media: entry.media)
        }
    }

    private func artwork() -> some View {
        LazyImage(source: player.metadata.imageSource) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fit)
        }
        .opacity(player.mediaType == .audio ? 1 : 0)
    }
}
