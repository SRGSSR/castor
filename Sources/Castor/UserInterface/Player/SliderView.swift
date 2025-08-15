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
                Text("Current position")
            },
            minimumValueLabel: {
                label(withText: Self.formattedTime(progressTracker.time, duration: progressTracker.timeRange.duration))
            },
            maximumValueLabel: {
                label(withText: Self.formattedTime(progressTracker.timeRange.duration, duration: progressTracker.timeRange.duration))
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
    func label(withText text: String?) -> some View {
        if let text {
            Text(text)
                .font(.caption)
                .monospacedDigit()
                .foregroundStyle(.primary)
        }
    }
}

private extension SliderView {
    static let shortFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.second, .minute]
        formatter.zeroFormattingBehavior = .pad
        return formatter
    }()

    static let longFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.second, .minute, .hour]
        formatter.zeroFormattingBehavior = .pad
        return formatter
    }()

    static func formattedTime(_ time: CMTime, duration: CMTime) -> String? {
        guard time.isValid, duration.isValid else { return nil }
        if duration.seconds < 60 * 60 {
            return shortFormatter.string(from: time.seconds)!
        }
        else {
            return longFormatter.string(from: time.seconds)!
        }
    }
}
