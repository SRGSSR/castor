//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

/// A Cast navigation mode.
///
/// Determines how items in a playback queue are navigated when using the following navigation APIs:
///
///   - ``CastPlayer/returnToPrevious()``
///   - ``CastPlayer/advanceToNext()``
public enum CastNavigationMode: Equatable {
    /// Immediate navigation.
    case immediate

    /// Smart navigation.
    ///
    /// Makes ``CastPlayer/returnToPrevious()`` jump to the start position of the current item when within the first
    /// few seconds of playback (as defined by the associated interval); otherwise, it returns to the previous item.
    ///
    /// > Note: This behavior is only relevant for on-demand streams.
    case smart(interval: TimeInterval)
}
