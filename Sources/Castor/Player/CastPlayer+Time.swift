//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import CoreMedia
import GoogleCast

public extension CastPlayer {
    /// Returns the current playback time.
    ///
    /// - Returns: The current time.
    func time() -> CMTime {
        remoteMediaClient.time()
    }

    /// Returns the time range within which seeking is possible.
    ///
    /// - Returns: The seekable time range.
    func seekableTimeRange() -> CMTimeRange {
        remoteMediaClient.seekableTimeRange()
    }
}
