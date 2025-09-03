//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

/// An option for media selection, such as audio or subtitle tracks.
public enum CastMediaSelectionOption: Hashable {
    /// Disabled.
    ///
    /// Some options may still be forced where applicable.
    case off

    /// Enabled.
    ///
    /// You can extract `AVMediaSelectionOption` characteristics for display.
    case on(CastMediaTrack)

    /// A display-friendly name.
    public var displayName: String {
        switch self {
        case .off:
            return String(localized: "Off", bundle: .module, comment: "Media selection option")
        case let .on(track):
            return track.displayName
        }
    }

    func hasLanguageCode(_ languageCode: String) -> Bool {
        switch self {
        case .off:
            return false
        case let .on(track):
            return track.languageCode == languageCode
        }
    }
}
