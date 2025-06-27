//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

/// A playback configuration.
public struct CastPlaybackConfiguration {
    /// Whether the item should automatically start playback when it becomes the current item in the
    /// queue. If `false`, the queue will pause when it reaches this item. The default value is
    /// `true`.
    public let autoplay: Bool

    /// Creates a playback configuration.
    public init(autoplay: Bool = true) {
        self.autoplay = autoplay
    }
}
