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
    var playbackSpeed: Float {
        get {
            _playbackSpeed
        }
        set {
            _playbackSpeed = newValue
        }
    }
}
