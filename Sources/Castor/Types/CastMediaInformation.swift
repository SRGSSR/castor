//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import GoogleCast

/// The media information useful for casting.
public struct CastMediaInformation {
    let rawMediaInformation: GCKMediaInformation

    /// The metadata.
    public var metadata: CastMetadata? {
        .init(rawMetadata: rawMediaInformation.metadata)
    }

    /// The URL of the content.
    public var url: URL? {
        rawMediaInformation.contentURL
    }

    /// The content identifier.
    public var identifier: String? {
        rawMediaInformation.contentID
    }

    init(rawMediaInformation: GCKMediaInformation) {
        self.rawMediaInformation = rawMediaInformation
    }
}
