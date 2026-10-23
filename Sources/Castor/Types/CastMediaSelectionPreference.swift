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

    /// A preference that disables media selection.
    ///
    /// Some options may still be forced where applicable.
    public static var off: Self {
        .init(kind: .off)
    }

    let kind: Kind

    private init(kind: Kind) {
        self.kind = kind
    }

    /// Returns a preference that enables media selection for a list of languages.
    ///
    /// - Parameter languages: An ordered list of language identifiers preferred for selection. Languages should be
    ///   specified using RFC 1766 tags.
    /// - Returns: The preference.
    public static func on(languages: String...) -> Self {
        .init(kind: .on(languages: languages))
    }
}
