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

    /// The image URL.
    public var imageUrl: URL? {
        (rawMetadata?.images().first as? GCKImage)?.url
    }

    init(rawMetadata: GCKMediaMetadata?) {
        self.rawMetadata = rawMetadata
    }

    /// Creates metadata.
    /// 
    /// - Parameters:
    ///   - title: The content title.
    ///   - imageUrl: The image URL.
    public init(title: String?, imageUrl: URL?) {
        rawMetadata = GCKMediaMetadata()
        if let title {
            rawMetadata?.setString(title, forKey: kGCKMetadataKeyTitle)
        }
        if let imageUrl {
            rawMetadata?.addImage(.init(url: imageUrl, width: 0, height: 0))
        }
    }
}
