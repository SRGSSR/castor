//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import CoreMedia

public extension CastPlayer {
    /// Checks whether skipping backward is possible.
    ///
    /// - Returns: `true` if possible.
    func canSkipBackward() -> Bool {
        seekableTimeRange().isValidAndNotEmpty
    }

    /// Checks whether skipping forward is possible.
    ///
    /// - Returns: `true` if possible.
    func canSkipForward() -> Bool {
        let seekableTimeRange = seekableTimeRange()
        guard seekableTimeRange.isValidAndNotEmpty else { return false }
        let currentTime = _targetSeekTime ?? time()
        return canSeek(to: currentTime + forwardSkipTime)
    }

    /// Checks whether skipping in some direction is possible.
    ///
    /// - Returns: `true` if possible.
    func canSkip(_ skip: CastSkip) -> Bool {
        switch skip {
        case .backward:
            return canSkipBackward()
        case .forward:
            return canSkipForward()
        }
    }

    /// Skips backward.
    func skipBackward() {
        let currentTime = _targetSeekTime ?? time()
        seek(to: CMTimeClampToRange(currentTime + backwardSkipTime, range: seekableTimeRange()))
    }

    /// Skips forward.
    func skipForward() {
        let currentTime = _targetSeekTime ?? time()
        seek(to: CMTimeClampToRange(currentTime + forwardSkipTime, range: seekableTimeRange()))
    }

    /// Skips in a given direction.
    ///
    /// - Parameter skip: The skip direction.
    func skip(_ skip: CastSkip) {
        switch skip {
        case .backward:
            skipBackward()
        case .forward:
            skipForward()
        }
    }
}

extension CastPlayer {
    var backwardSkipTime: CMTime {
        CMTime(seconds: -configuration.backwardSkipInterval, preferredTimescale: 1)
    }

    var forwardSkipTime: CMTime {
        CMTime(seconds: configuration.forwardSkipInterval, preferredTimescale: 1)
    }
}
