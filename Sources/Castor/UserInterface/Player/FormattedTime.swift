//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import CoreMedia

struct FormattedTime {
    let positional: String
    let full: String

    init?(time: CMTime, duration: CMTime) {
        guard let positional = Self.formattedTime(time, duration: duration, unitsStyle: .positional),
              let full = Self.formattedTime(time, duration: duration, unitsStyle: .full) else {
            return nil
        }
        self.positional = positional
        self.full = full
    }

    init?(duration: CMTime) {
        self.init(time: duration, duration: duration)
    }
}

private extension FormattedTime {
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

    private static func formattedTime(_ time: CMTime, duration: CMTime, unitsStyle: DateComponentsFormatter.UnitsStyle) -> String? {
        guard time.isValid, duration.isValid else { return nil }
        if duration.seconds < 60 * 60 {
            return shortFormatters[unitsStyle]?.string(from: time.seconds)
        }
        else {
            return longFormatters[unitsStyle]?.string(from: time.seconds)
        }
    }
}
