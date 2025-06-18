//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

public extension CastPlayer {
    /// The currently allowed playback speed range.
    var playbackSpeedRange: ClosedRange<Float> {
        streamType == .buffered ? 0.5...2 : 1...1
    }

    /// The currently applicable playback speed.
    var playbackSpeed: Float {
        get {
            _playbackSpeed
        }
        set {
            _playbackSpeed = newValue
        }
    }
}
