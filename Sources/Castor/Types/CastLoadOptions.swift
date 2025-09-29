//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import CoreMedia
import GoogleCast

/// Options used when loading assets.
public struct CastLoadOptions {
    /// The index of the item at which playback should start.
    public let startIndex: Int

    /// The time at which playback should start.
    ///
    /// `.invalid` for the default position.
    public let startTime: CMTime

    /// A Boolean value that indicates whether the player should automatically play content when possible.
    public let shouldPlay: Bool

    /// The playback speed to apply.
    public let playbackSpeed: Float

    /// The mode that determines how the player repeats playback of items in its queue.
    public let repeatMode: CastRepeatMode

    /// Creates loading options.
    ///
    /// - Parameters:
    ///   - startIndex: The index of the item at which playback should start.
    ///   - startTime: The time at which playback should start. Use `.invalid` for the default position.
    ///   - shouldPlay: A Boolean value that indicates whether the player should automatically play content when possible.
    ///   - playbackSpeed: The playback speed to apply.
    ///   - repeatMode: The mode that determines how the player repeats playback of items in its queue.
    public init(
        startIndex: Int = 0,
        startTime: CMTime = .invalid,
        shouldPlay: Bool = true,
        playbackSpeed: Float = 1,
        repeatMode: CastRepeatMode = .off
    ) {
        self.startIndex = max(startIndex, 0)
        self.startTime = startTime
        self.shouldPlay = shouldPlay
        self.playbackSpeed = playbackSpeed.clamped(to: 0.5...2)
        self.repeatMode = repeatMode
    }
}
