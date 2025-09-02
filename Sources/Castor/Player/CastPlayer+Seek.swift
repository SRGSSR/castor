//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import CoreMedia

public extension CastPlayer {
    /// Checks whether it is possible to seek to a specific time.
    ///
    /// - Parameter time: The target time to seek to.
    /// - Returns: `true` if seeking to the specified time is possible.
    func canSeek(to time: CMTime) -> Bool {
        let seekableTimeRange = seekableTimeRange()
        guard seekableTimeRange.isValidAndNotEmpty else { return false }
        return seekableTimeRange.start <= time && time <= seekableTimeRange.end
    }

    /// Seeks to the specified time.
    ///
    /// - Parameter time: The target time to seek to.
    func seek(to time: CMTime) {
        _targetSeekTime = time
    }
}
