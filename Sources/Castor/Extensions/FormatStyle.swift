//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import CoreMedia

/// A style for formatting a player time interval in a short format. For example, one hour is formatted as "60:00".
public struct PlayerTimeShortFormatStyle: FormatStyle {
    // swiftlint:disable:next missing_docs
    public func format(_ time: CMTime) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.second, .minute]
        formatter.zeroFormattingBehavior = .pad
        if time.isValid, let format = formatter.string(from: time.seconds) {
            return format
        }
        else {
            return ""
        }
    }
}

/// A style for formatting a player time interval in a long format. For example, one hour is formatted as "01:00:00".
public struct PlayerTimeLongFormatStyle: FormatStyle {
    // swiftlint:disable:next missing_docs
    public func format(_ time: CMTime) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.second, .minute, .hour]
        formatter.zeroFormattingBehavior = .pad
        if time.isValid, let format = formatter.string(from: time.seconds) {
            return format
        }
        else {
            return ""
        }
    }
}

/// A style for formatting a player time interval in an adaptive format.
/// For example, one hour is formatted as "01:00:00", and fifty-nine minutes is formatted as "59:00".
public struct PlayerTimeAdaptiveFormatStyle: FormatStyle {
    let duration: TimeInterval

    // swiftlint:disable:next missing_docs
    public func format(_ time: CMTime) -> String {
        guard duration > 0 else { return "" }
        if duration < 60 * 60 {
            return PlayerTimeShortFormatStyle().format(time)
        }
        else {
            return PlayerTimeLongFormatStyle().format(time)
        }
    }
}

public extension FormatStyle where Self == PlayerTimeShortFormatStyle {
    /// A pre-defined style for showing a player time in a short format.
    /// For example, "03:14".
    static var shortPlayerTime: Self {
        .init()
    }
}

public extension FormatStyle where Self == PlayerTimeLongFormatStyle {
    /// A pre-defined style for showing a player time in a long format.
    /// For example, "16:18:03".
    static var longPlayerTime: Self {
        .init()
    }
}

public extension FormatStyle where Self == PlayerTimeAdaptiveFormatStyle {
    /// A pre-defined style for showing a player time in either short or long format, depending on the duration.
    ///
    /// - Parameter duration: The duration in seconds used for formatting.
    ///     - If the duration is less than one hour, the format will be "03:14".
    ///     - If the duration is one hour or more, the format will be "16:18:03".
    static func adaptivePlayerTime(duration: TimeInterval) -> Self {
        .init(duration: duration)
    }
}
