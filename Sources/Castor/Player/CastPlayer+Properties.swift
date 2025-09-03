//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import GoogleCast

public extension CastPlayer {
    /// The current state of the player.
    var state: GCKMediaPlayerState {
        _mediaStatus?.playerState ?? .unknown
    }

    /// The asset that is currently being played, if any.
    var currentAsset: CastAsset? {
        .init(rawMediaInformation: rawMediaInformation)
    }

    /// A Boolean value indicating whether the player is currently busy.
    var isBusy: Bool {
        state == .buffering || state == .loading
    }

    /// A Boolean value indicating whether the player is active.
    ///
    /// Actions performed on an inactive player typically have no effect. User interfaces should generally disable or hide
    /// controls when the player is inactive.
    var isActive: Bool {
        remoteMediaClient.canMakeRequest()
    }

    /// The type of stream that is currently being played.
    var streamType: GCKMediaStreamType {
        rawMediaInformation?.streamType ?? .none
    }
}

extension CastPlayer {
    var rawMediaInformation: GCKMediaInformation? {
        _mediaStatus?.mediaInformation
    }
}
