//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

public extension CastPlayer {
    /// A Boolean value that indicates whether the player should automatically play content when possible.
    ///
    /// > Note: Use ``CastLoadOptions`` to configure behavior when loading items.
    var shouldPlay: Bool {
        get {
            _shouldPlay
        }
        set {
            _shouldPlay = newValue
        }
    }

    /// Starts playback.
    func play() {
        shouldPlay = true
    }

    /// Pauses playback.
    func pause() {
        shouldPlay = false
    }

    /// Toggles playback between play and pause.
    func togglePlayPause() {
        shouldPlay.toggle()
    }

    /// Stops playback.
    func stop() {
        remoteMediaClient.stop()
    }
}
