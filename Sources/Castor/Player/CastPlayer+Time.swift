//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import CoreMedia
import GoogleCast

public extension CastPlayer {
    /// The current playback time.
    func time() -> CMTime {
        remoteMediaClient.time()
    }

    /// The time range within which seeking is possible.
    func seekableTimeRange() -> CMTimeRange {
        remoteMediaClient.seekableTimeRange()
    }
}
