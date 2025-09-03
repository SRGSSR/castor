//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import CoreMedia
import GoogleCast

/// Options used when loading assets.
public struct CastLoadOptions {
    let rawOptions = GCKMediaQueueLoadOptions()

    /// Creates loading options.
    ///
    /// - Parameters:
    ///   - startTime: The time at which playback should start.
    ///   - startIndex: The index of the item at which playback should start.
    public init(startTime: CMTime = .invalid, startIndex: Int = 0) {
        if startTime.isValid {
            rawOptions.playPosition = startTime.seconds
        }
        rawOptions.startIndex = UInt(max(startIndex, 0))
    }
}
