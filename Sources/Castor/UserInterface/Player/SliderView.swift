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

    private func text(_ time: CMTime) -> some View {
        Group {
            if !progressTracker.timeRange.isEmpty {
                if progressTracker.timeRange.duration.seconds < 60 * 60 {
                    Text(time, format: .shortPlayerTime)
                }
                else {
                    Text(time, format: .longPlayerTime)
                }
            }
        }
        .font(.caption)
        .monospacedDigit()
        .foregroundColor(.primary)
    }
}
