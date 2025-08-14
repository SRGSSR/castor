//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import CoreMedia
import SwiftUI

extension CMTime {
    private static let shortFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.zeroFormattingBehavior = .pad
        return formatter
    }()

    private static let longFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
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
