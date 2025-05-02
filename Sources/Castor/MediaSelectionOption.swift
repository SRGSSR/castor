//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import GoogleCast

/// An option for media selection (audible, legible, etc.).
public struct MediaSelectionOption {
    private let rawTrack: GCKMediaTrack

    var trackIdentifier: Int {
        rawTrack.identifier
    }

    init(rawTrack: GCKMediaTrack) {
        self.rawTrack = rawTrack
    }
}
