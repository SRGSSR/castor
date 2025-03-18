//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation
import GoogleCast

/// An cast asset representing content to be played.
public enum CastAsset {
    /// Simple assets which can be played directly.
    case simple(URL)

    /// Custom assets which require a custom identifier.
    case custom(String)

    func mediaInformationBuilder() -> GCKMediaInformationBuilder {
        switch self {
        case let .simple(url):
            return GCKMediaInformationBuilder(contentURL: url)
        case let .custom(id):
            let builder = GCKMediaInformationBuilder()
            builder.contentID = id
            return builder
        }
    }
}
