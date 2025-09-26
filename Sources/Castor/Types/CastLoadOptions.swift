//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import CoreMedia
import GoogleCast

/// Options used when loading assets.
public struct CastLoadOptions {
    public let startTime: CMTime
    public let startIndex: Int
    public let shouldPlay: Bool
    public let playbackSpeed: Float
    public let repeatMode: CastRepeatMode

    /// Creates loading options.
    ///
    /// - Parameters:
    ///   - startTime: The time at which playback should start. Use `.invalid` for the default position.
    ///   - startIndex: The index of the item at which playback should start.
    public init(
        startTime: CMTime = .invalid,
        startIndex: Int = 0,
        shouldPlay: Bool = true,
        playbackSpeed: Float = 1,
        repeatMode: CastRepeatMode = .off
    ) {
        self.startTime = startTime
        self.startIndex = max(startIndex, 0)
        self.shouldPlay = shouldPlay
        self.playbackSpeed = playbackSpeed
        self.repeatMode = repeatMode
    }
}
