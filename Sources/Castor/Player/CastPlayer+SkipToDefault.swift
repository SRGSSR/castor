//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import CoreMedia

public extension CastPlayer {
    /// Checks whether it is possible to skip to the default position of the current item.
    ///
    /// - Returns: `true` if skipping to the default position is possible; otherwise, `false`.
    ///
    /// For a livestream with DVR support, this method can be used to determine whether the stream is currently
    /// playing at the live edge, in which case it returns `false`.
    func canSkipToDefault() -> Bool {
        switch streamType {
        case .live where seekableTimeRange().isValidAndNotEmpty:
            return time() < seekableTimeRange().end - forwardSkipTime
        case .live:
            return false
        case .buffered:
            return true
        default:
            return false
        }
    }

    /// Skips to the default position of the current item.
    ///
    /// For on-demand content, the default position is the start. For a livestream with DVR support, it is the live edge.
    func skipToDefault() {
        switch streamType {
        case .live:
            seek(to: seekableTimeRange().end)
        case .buffered:
            seek(to: seekableTimeRange().start)
        default:
            return
        }
    }
}
