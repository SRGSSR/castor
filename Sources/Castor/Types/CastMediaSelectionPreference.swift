//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

/// A preferred option for media selection, such as audio or subtitle tracks.
public struct CastMediaSelectionPreference {
    enum Kind {
        case off
        case on(languages: [String])
    }

    /// Disabled.
    ///
    /// Some options may still be forced where applicable.
    public static var off: Self {
        .init(kind: .off)
    }

    let kind: Kind

    private init(kind: Kind) {
        self.kind = kind
    }

    /// Enabled.
    ///
    /// - Parameter languages: An ordered list of language identifiers preferred for selection. Languages should be
    ///   specified using RFC 1766 tags.
    public static func on(languages: String...) -> Self {
        .init(kind: .on(languages: languages))
    }
}
