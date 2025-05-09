//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import GoogleCast

/// A mode setting how a player repeats playback of items in its queue.
public enum CastRepeatMode {
    /// Disabled.
    case off

    /// Repeat the current item.
    case one

    /// Repeat all items.
    case all

    init?(rawMode: GCKMediaRepeatMode) {
        switch rawMode {
        case .off:
            self = .off
        case .single:
            self = .one
        case .all, .allAndShuffle:
            self = .all
        default:
            return nil
        }
    }

    func rawMode() -> GCKMediaRepeatMode {
        switch self {
        case .off:
            return .off
        case .one:
            return .single
        case .all:
            return .all
        }
    }
}
