//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import GoogleCast

public extension CastPlayer {
    /// Player state.
    var state: GCKMediaPlayerState {
        _mediaStatus?.playerState ?? .unknown
    }

    /// Media information.
    var mediaInformation: GCKMediaInformation? {
        _mediaStatus?.mediaInformation
    }

    /// Returns if the player is busy.
    var isBusy: Bool {
        state == .buffering || state == .loading
    }

    /// A Boolean value whether the player is active.
    ///
    /// Actions performed on an inactive player will usually do nothing. User interfaces should usually disable or hide
    /// controls when a player is not active.
    var isActive: Bool {
        remoteMediaClient.canMakeRequest()
    }

    /// The type of stream currently being played.
    var streamType: GCKMediaStreamType {
        mediaInformation?.streamType ?? .none
    }
}
