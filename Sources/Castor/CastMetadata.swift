//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import GoogleCast

/// Metadata associated to an item.
public struct CastMetadata {
    let rawMetadata: GCKMediaMetadata

    /// Creates metadata.
    ///
    /// - Parameter title: The content title.
    public init(title: String?) {
        rawMetadata = GCKMediaMetadata()
        if let title {
            rawMetadata.setString(title, forKey: kGCKMetadataKeyTitle)
        }
    }
}
