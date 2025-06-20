//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import SwiftUI

private struct PlaybackSpeedMenuContent: View {
    let speeds: Set<Float>
    let action: (Float) -> Void

    @ObservedObject var player: CastPlayer

    var body: some View {
        Picker(selection: selection) {
            ForEach(playbackSpeeds, id: \.self) { speed in
                Text("\(speed, specifier: "%g×")", comment: "Speed multiplier").tag(speed)
            }
        } label: {
            EmptyView()
        }
        .pickerStyle(.inline)
    }

    private var playbackSpeeds: [Float] {
        speeds.filter { speed in
            player.playbackSpeedRange.contains(speed)
        }
        .sorted()
    }

    private var selection: Binding<Float> {
        .init {
            player.playbackSpeed
        } set: { newValue in
            player.playbackSpeed = newValue
            action(newValue)
        }
    }
}

private struct MediaSelectionMenuContent: View {
    let characteristic: AVMediaCharacteristic
    let action: (CastMediaSelectionOption) -> Void

    @ObservedObject var player: CastPlayer

    var body: some View {
        Picker(selection: selection(for: characteristic)) {
            ForEach(mediaOptions, id: \.self) { option in
                Text(option.displayName).tag(option)
            }
        } label: {
            EmptyView()
        }
        .pickerStyle(.inline)
    }

    private var mediaOptions: [CastMediaSelectionOption] {
        player.mediaSelectionOptions(for: characteristic)
    }

    private func selection(for characteristic: AVMediaCharacteristic) -> Binding<CastMediaSelectionOption> {
        .init {
            player.mediaOption(for: characteristic).wrappedValue
        } set: { newValue in
            player.mediaOption(for: characteristic).wrappedValue = newValue
            action(newValue)
        }
    }
}

private struct SettingsMenuContent: View {
    @ObservedObject var player: CastPlayer

    let speeds: Set<Float>
    let action: (CastSettingsUpdate) -> Void

    var body: some View {
        playbackSpeedMenu()
        audibleMediaSelectionMenu()
        legibleMediaSelectionMenu()
    }

    private func playbackSpeedMenu() -> some View {
        Menu {
            player.playbackSpeedMenu(speeds: speeds) { speed in
                action(.playbackSpeed(speed))
            }
        } label: {
            Button(action: {}) {
                Text("Playback Speed", bundle: .module, comment: "Playback setting menu title")
                Text("\(player.playbackSpeed, specifier: "%g×")", comment: "Speed multiplier")
                Image(systemName: "speedometer")
            }
        }
    }

    private func audibleMediaSelectionMenu() -> some View {
        Menu {
            mediaSelectionMenuContent(characteristic: .audible)
        } label: {
            Button(action: {}) {
                Text("Audio", bundle: .module, comment: "Playback setting menu title")
                Text(player.selectedMediaOption(for: .audible).displayName)
                Image(systemName: "waveform.circle")
            }
        }
    }

    private func legibleMediaSelectionMenu() -> some View {
        Menu {
            mediaSelectionMenuContent(characteristic: .legible)
        } label: {
            Button(action: {}) {
                Text("Subtitles", bundle: .module, comment: "Playback setting menu title")
                Text(player.selectedMediaOption(for: .legible).displayName)
                Image(systemName: "captions.bubble")
            }
        }
    }

    private func mediaSelectionMenuContent(characteristic: AVMediaCharacteristic) -> some View {
        player.mediaSelectionMenu(characteristic: characteristic) { option in
            action(.mediaSelection(characteristic: characteristic, option: option))
        }
    }
}

public extension CastPlayer {
    /// Returns content for a standard player settings menu.
    ///
    /// - Parameters:
    ///    - speeds: The offered playback speeds.
    ///    - action: The action to perform when the user interacts with an item from the menu.
    ///
    /// The returned view is meant to be used as content of a `Menu`. Using it for any other purpose has undefined
    /// behavior.
    func standardSettingsMenu(
        speeds: Set<Float> = [0.5, 1, 1.25, 1.5, 2],
        action: @escaping (_ update: CastSettingsUpdate) -> Void = { _ in }
    ) -> some View {
        SettingsMenuContent(player: self, speeds: speeds, action: action)
    }

    /// Returns content for a playback speed menu.
    ///
    /// - Parameters:
    ///    - speeds: The offered playback speeds.
    ///    - action: The action to perform when the user interacts with an item from the menu.
    ///
    /// The returned view is meant to be used as content of a `Menu`. Using it for any other purpose has undefined
    /// behavior.
    func playbackSpeedMenu(
        speeds: Set<Float> = [0.5, 1, 1.25, 1.5, 2],
        action: @escaping (_ speed: Float) -> Void = { _ in }
    ) -> some View {
        PlaybackSpeedMenuContent(speeds: speeds, action: action, player: self)
    }

    /// Returns content for a media selection menu.
    ///
    /// - Parameters:
    ///    - characteristic: The characteristic for which selection is made.
    ///    - action: The action to perform when the user interacts with an item from the menu.
    ///
    /// The returned view is meant to be used as content of a `Menu`. Using it for any other purpose has undefined
    /// behavior.
    func mediaSelectionMenu(
        characteristic: AVMediaCharacteristic,
        action: @escaping (_ option: CastMediaSelectionOption) -> Void = { _ in }
    ) -> some View {
        MediaSelectionMenuContent(characteristic: characteristic, action: action, player: self)
    }
}
