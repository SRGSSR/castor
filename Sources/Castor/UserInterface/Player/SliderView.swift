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
        HStack {
            if progressTracker.isProgressAvailable {
                slider()
            }
            if player.streamType == .live {
                skipToDefaultButton()
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
                Text("Current position")
            },
            minimumValueLabel: {
                text(progressTracker.time)
            },
            maximumValueLabel: {
                text(progressTracker.timeRange.duration)
            }
        )
    }

    func skipToDefaultButton() -> some View {
        Button(action: player.skipToDefault) {
            LiveLabel(player: player)
        }
        .disabled(!player.canSkipToDefault())
    }

    @ViewBuilder
    private func text(_ time: CMTime) -> some View {
        if !progressTracker.timeRange.isEmpty {
            Text(time, format: .adaptivePlayerTime(duration: progressTracker.timeRange.duration.seconds))
                .font(.caption)
                .monospacedDigit()
                .foregroundColor(.primary)
        }
    }
}
