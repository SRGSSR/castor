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
    ///   - images: The associated images.
    public init(title: String?, images: [CastImage] = []) {
        rawMetadata = GCKMediaMetadata()
        if let title {
            rawMetadata?.setString(title, forKey: kGCKMetadataKeyTitle)
        }
        images.forEach { image in
            guard let rawImage = image.rawImage else { return }
            rawMetadata?.addImage(rawImage)
        }
    }

    /// Creates metadata.
    ///
    /// - Parameters:
    ///   - title: The content title.
    ///   - image: The associated image.
    public init(title: String?, image: CastImage) {
        self.init(title: title, images: [image])
    }
}
