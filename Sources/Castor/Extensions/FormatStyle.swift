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
