//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import GoogleCast

/// An option for media selection (audible, legible, etc.).
public struct CastMediaTrack: Hashable {
    private let rawTrack: GCKMediaTrack

    var trackIdentifier: Int {
        rawTrack.identifier
    }

    var displayName: String {
        "-->"
    }

    init(rawTrack: GCKMediaTrack) {
        self.rawTrack = rawTrack
    }
}

/// An option for media selection (audible, legible, etc.).
public enum CastMediaSelectionOption: Hashable {
    /// Disabled.
    ///
    /// Options might still be forced where applicable.
    case off

    /// Enabled.
    ///
    /// You can extract `AVMediaSelectionOption` characteristics for display purposes.
    case on(CastMediaTrack)

    /// A name suitable for display.
    public var displayName: String {
        switch self {
        case .off:
            return String(localized: "Off", bundle: .module, comment: "Subtitle selection option")
        case let .on(option):
            return option.displayName
        }
    }
}
