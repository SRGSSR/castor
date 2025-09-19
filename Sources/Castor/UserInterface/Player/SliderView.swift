//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import CoreMedia
import SwiftUI

struct SliderView: View {
    @StateObject private var progressTracker = CastProgressTracker(interval: .init(value: 1, timescale: 10))
    @ObservedObject var player: CastPlayer

    var body: some View {
        ZStack {
            if progressTracker.isProgressAvailable {
                HStack {
                    slider()
                    skipToDefaultButton()
                }
            }
            else {
                slider()
                    .hidden()
                    .overlay(content: skipToDefaultButton)
            }
        }
        .bind(progressTracker, to: player)
    }
}

private extension SliderView {
    func slider() -> some View {
        Slider(
            progressTracker: progressTracker,
            label: {
                Text("Current position", bundle: .module, comment: "Label associated with the seek bar")
            },
            minimumValueLabel: {
                if let time = FormattedTime(time: progressTracker.time, duration: progressTracker.timeRange.duration) {
                    label(
                        text: time.positional,
                        accessibilityLabel: String(localized: "\(time.full) elapsed", bundle: .module, comment: "Elapsed time accessibility label")
                    )
                }
            },
            maximumValueLabel: {
                if let time = FormattedTime(duration: progressTracker.timeRange.duration) {
                    label(
                        text: time.positional,
                        accessibilityLabel: String(localized: "\(time.full) total", bundle: .module, comment: "Total time accessibility label")
                    )
                }
            }
        )
    }

    @ViewBuilder
    func skipToDefaultButton() -> some View {
        if player.streamType == .live {
            Button(action: player.skipToDefault) {
                LiveLabel(player: player)
            }
            .disabled(!player.canSkipToDefault())
        }
    }

    @ViewBuilder
    func label(text: String, accessibilityLabel: String) -> some View {
        Text(text)
            .font(.caption)
            .monospacedDigit()
            .foregroundStyle(.primary)
            .accessibilityLabel(accessibilityLabel)
    }
}
