//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

/// A playback configuration.
public struct CastPlaybackConfiguration: Sendable {
    /// The default configuration.
    public static let `default` = Self()

    /// The time to start playback at.
    ///
    /// When the time is `.invalid`, playback starts at the default position:
    ///
    /// - Zero for an on-demand stream.
    /// - Live edge for a livestream supporting DVR.
    public let startTime: CMTime

    /// Whether the item should automatically start playback when it becomes the current item in the
    /// queue. If `false`, the queue will pause when it reaches this item. The default value is
    /// `true`.
    public let autoplay: Bool

    /// Creates a playback configuration.
    public init(startTime: CMTime = .invalid, autoplay: Bool = true) {
        self.startTime = startTime
        self.autoplay = autoplay
    }
}
