//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import CoreMedia
import GoogleCast

/// Options for loading assets.
public struct CastLoadOptions {
    let rawOptions = GCKMediaQueueLoadOptions()

    /// Creates options.
    /// - Parameters:
    ///   - startTime: The start time.
    ///   - startIndex: The start index.
    public init(startTime: CMTime = .invalid, startIndex: Int = 0) {
        if startTime.isValid {
            rawOptions.playPosition = startTime.seconds
        }
        rawOptions.startIndex = UInt(max(startIndex, 0))
    }
}
