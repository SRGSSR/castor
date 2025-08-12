//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import GoogleCast

public extension CastPlayer {
    /// The player state.
    var state: GCKMediaPlayerState {
        _mediaStatus?.playerState ?? .unknown
    }

    /// The asset currently being played, if any.
    var currentAsset: CastAsset? {
        .init(rawMediaInformation: rawMediaInformation)
    }

    /// A Boolean value indicating whether the player is busy or not.
    var isBusy: Bool {
        state == .buffering || state == .loading
    }

    /// A Boolean value indicating whether the player is active or not.
    ///
    /// Actions performed on an inactive player will usually do nothing. User interfaces should usually disable or hide
    /// controls when a player is not active.
    var isActive: Bool {
        remoteMediaClient.canMakeRequest()
    }

    /// A Boolean value indicating whether the player is empty or not.
    ///
    /// > Note: While a playlist is being retrieved, ``CastPlayer/items`` may still be empty even if the player is
    ///   already considered non-empty.
    var isEmpty: Bool {
        currentAsset == nil
    }

    /// The type of stream currently being played.
    var streamType: GCKMediaStreamType {
        rawMediaInformation?.streamType ?? .none
    }
}

extension CastPlayer {
    var rawMediaInformation: GCKMediaInformation? {
        _mediaStatus?.mediaInformation
    }
}
