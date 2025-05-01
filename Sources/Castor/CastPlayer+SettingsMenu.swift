//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

private struct SettingsMenuContent: View {
    let player: CastPlayer
    let speeds: Set<Float>
    let action: (CastSettingsUpdate) -> Void

    var body: some View {
        playbackSpeedMenu()
    }

    private func playbackSpeedMenu() -> some View {
        Menu {
            player.playbackSpeedMenu(speeds: speeds) { speed in
                action(.playbackSpeed(speed))
            }
        } label: {
            Label {
                Text("Playback Speed", bundle: .module, comment: "Playback setting menu title")
            } icon: {
                Image(systemName: "speedometer")
            }
        }
    }
}

private struct PlaybackSpeedMenuContent: View {
    let speeds: Set<Float>
    let action: (Float) -> Void

    @ObservedObject var player: CastPlayer

    var body: some View {
        Picker("Playback Speed", selection: selection) {
            ForEach(playbackSpeeds, id: \.self) { speed in
                Text("\(speed, specifier: "%g×")", comment: "Speed multiplier").tag(speed)
            }
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
            player.playbackSpeed.wrappedValue
        } set: { newValue in
            player.playbackSpeed.wrappedValue = newValue
            action(newValue)
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
}
