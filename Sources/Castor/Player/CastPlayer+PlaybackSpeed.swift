//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

public extension CastPlayer {
    /// The range of playback speeds currently allowed.
    var playbackSpeedRange: ClosedRange<Float> {
        streamType == .buffered ? 0.5...2 : 1...1
    }

    /// The playback speed currently in effect.
    ///
    /// Values outside ``CastPlayer/playbackSpeedRange`` are clamped to it.
    ///
    /// > Note: Use ``CastLoadOptions`` to configure behavior when loading items.
    var playbackSpeed: Float {
        get {
            _playbackSpeed
        }
        set {
            _playbackSpeed = newValue.clamped(to: playbackSpeedRange)
        }
    }
}
