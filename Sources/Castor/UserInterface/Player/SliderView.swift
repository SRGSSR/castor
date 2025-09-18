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
                labelForTime(progressTracker.time, duration: progressTracker.timeRange.duration)
            },
            maximumValueLabel: {
                labelForTime(progressTracker.timeRange.duration, duration: progressTracker.timeRange.duration)
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
    func labelForTime(_ time: CMTime, duration: CMTime) -> some View {
        if let text = Self.formattedTime(time, duration: duration, unitsStyle: .positional),
           let accessibilityLabel = Self.formattedTime(time, duration: duration, unitsStyle: .full) {
            Text(text)
                .font(.caption)
                .monospacedDigit()
                .foregroundStyle(.primary)
                .accessibilityLabel(accessibilityLabel)
        }
    }
}

private extension SliderView {
    private static let shortFormatters: [DateComponentsFormatter.UnitsStyle: DateComponentsFormatter] = [
        .positional: shortFormatter(unitsStyle: .positional),
        .full: shortFormatter(unitsStyle: .full)
    ]

    private static let longFormatters: [DateComponentsFormatter.UnitsStyle: DateComponentsFormatter] = [
        .positional: longFormatter(unitsStyle: .positional),
        .full: longFormatter(unitsStyle: .full)
    ]

    private static func shortFormatter(unitsStyle: DateComponentsFormatter.UnitsStyle) -> DateComponentsFormatter {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.second, .minute]
        formatter.unitsStyle = unitsStyle
        formatter.zeroFormattingBehavior = .pad
        return formatter
    }

    private static func longFormatter(unitsStyle: DateComponentsFormatter.UnitsStyle) -> DateComponentsFormatter {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = unitsStyle
        formatter.zeroFormattingBehavior = .pad
        return formatter
    }

    static func formattedTime(_ time: CMTime, duration: CMTime, unitsStyle: DateComponentsFormatter.UnitsStyle) -> String? {
        guard time.isValid, duration.isValid else { return nil }
        if duration.seconds < 60 * 60 {
            return shortFormatters[unitsStyle]?.string(from: time.seconds)
        }
        else {
            return longFormatters[unitsStyle]?.string(from: time.seconds)
        }
    }
}
