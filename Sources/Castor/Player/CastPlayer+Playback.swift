//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

public extension CastPlayer {
    /// A Boolean value whether the player should play content when possible.
    var shouldPlay: Bool {
        get {
            _shouldPlay
        }
        set {
            _shouldPlay = newValue
        }
    }

    /// Plays.
    func play() {
        shouldPlay = true
    }

    /// Pauses.
    func pause() {
        shouldPlay = false
    }

    /// Toggles between play and pause.
    func togglePlayPause() {
        shouldPlay.toggle()
    }

    /// Stops.
    func stop() {
        remoteMediaClient.stop()
    }
}
