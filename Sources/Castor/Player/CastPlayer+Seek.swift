//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import CoreMedia

public extension CastPlayer {
    /// Checks whether seeking to a specific time is possible.
    ///
    /// - Parameter time: The time to seek to.
    /// - Returns: `true` if possible.
    func canSeek(to time: CMTime) -> Bool {
        let seekableTimeRange = seekableTimeRange()
        guard seekableTimeRange.isValidAndNotEmpty else { return false }
        return seekableTimeRange.start <= time && time <= seekableTimeRange.end
    }

    /// Performs a seek to a given time.
    ///
    /// - Parameter time: The time to reach.
    func seek(to time: CMTime) {
        _targetSeekTime = time
    }
}
