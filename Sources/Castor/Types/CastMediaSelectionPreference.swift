//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

/// A preference for media selection (audible, legible, etc.).
public struct CastMediaSelectionPreference {
    enum Kind {
        case off
        case on(languages: [String])
    }

    /// Disabled.
    ///
    /// Options might still be forced where applicable.
    public static var off: Self {
        .init(kind: .off)
    }

    let kind: Kind

    private init(kind: Kind) {
        self.kind = kind
    }

    /// Enabled.
    ///
    /// - Parameter languages: A list of strings containing language identifiers, in order of desirability, that are
    ///   preferred for selection. Languages must be indicated via RFC 1766 tags.
    public static func on(languages: String...) -> Self {
        .init(kind: .on(languages: languages))
    }
}
