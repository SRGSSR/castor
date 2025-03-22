//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import GoogleCast

/// Metadata associated to an item.
public struct CastMetadata {
    let rawMetadata: GCKMediaMetadata?

    /// The content title.
    public var title: String? {
        rawMetadata?.string(forKey: kGCKMetadataKeyTitle)
    }

    /// Creates metadata.
    ///
    /// - Parameter title: The content title.
    public init(title: String?, imageUrl: URL?) {
        let rawMetadata = GCKMediaMetadata()
        if let title {
            rawMetadata.setString(title, forKey: kGCKMetadataKeyTitle)
        }
        if let imageUrl {
            rawMetadata.removeAllMediaImages()
            rawMetadata.addImage(.init(url: imageUrl, width: 0, height: 0))
        }
        self.init(rawMetadata: rawMetadata)
    }

    init(rawMetadata: GCKMediaMetadata?) {
        self.rawMetadata = rawMetadata
    }
}
