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
        return item.asset?.metadata?.title ?? "Unknown"
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
        .foregroundStyle(.white)
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

private struct RemoteSettingsMenu: View {
    @AppStorage(UserDefaults.DemoSettingKey.routePicker)
    private var routePicker: RoutePicker = .button

    let player: CastPlayer

    var body: some View {
        Menu {
            player.standardSettingsMenu()
            RemoteRepeatModeMenu(player: player)
            if routePicker == .menu {
                DeviceMenu()
            }
        } label: {
            Image(systemName: "ellipsis.circle")
                .font(.system(size: 20))
                .tint(.white)
        }
        .menuOrder(.fixed)
    }
}

private struct RemoteRepeatModeMenu: View {
    @ObservedObject var player: CastPlayer

    var body: some View {
        Menu {
            Picker(selection: $player.repeatMode) {
                ForEach(CastRepeatMode.allCases, id: \.self) { mode in
                    Text(mode.name).tag(mode)
                }
            } label: {
                EmptyView()
            }
            .pickerStyle(.inline)
        } label: {
            Label("Repeat", systemImage: "repeat.circle")
            Text(player.repeatMode.name)
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
                .tint(.white)
        }
        else {
            Button(action: player.togglePlayPause) {
                Image(systemName: player.shouldPlay ? "pause.fill" : "play.fill")
            }
            .font(.system(size: 44))
            .foregroundStyle(.white)
        }
    }

    private func controls() -> some View {
        ZStack {
            Color.black.opacity(0.4)
            playbackButton()
            bottomBar()
        }
        .disabled(!player.isActive)
    }

    private func bottomBar() -> some View {
        HStack {
            RemoteTimeBar(player: player)
            RemoteSettingsMenu(player: player)
        }
        .padding()
        .frame(maxHeight: .infinity, alignment: .bottom)
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
