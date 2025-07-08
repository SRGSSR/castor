//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import CoreMedia
import GoogleCast

public extension CastPlayer {
    /// Time.
    func time() -> CMTime {
        remoteMediaClient.time()
    }

    /// Seekable time range.
    func seekableTimeRange() -> CMTimeRange {
        remoteMediaClient.seekableTimeRange()
    }
}
