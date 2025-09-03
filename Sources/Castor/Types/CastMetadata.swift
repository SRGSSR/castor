//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import GoogleCast

/// Metadata associated with an asset.
public struct CastMetadata {
    let rawMetadata: GCKMediaMetadata

    /// The title of the content.
    public var title: String? {
        rawMetadata.string(forKey: kGCKMetadataKeyTitle)
    }

    init?(rawMetadata: GCKMediaMetadata?) {
        guard let rawMetadata else { return nil }
        self.rawMetadata = rawMetadata
    }

    /// Creates metadata.
    ///
    /// - Parameters:
    ///   - title: The title of the content.
    ///   - metadataType: The type of the metadata.
    ///   - images: The associated images.
    ///
    /// The metadata type helps receivers adjust their layout according to the type of content being played.
    public init(
        title: String?,
        metadataType: GCKMediaMetadataType = .generic,
        images: [CastImage] = []
    ) {
        rawMetadata = GCKMediaMetadata(metadataType: metadataType)
        if let title {
            rawMetadata.setString(title, forKey: kGCKMetadataKeyTitle)
        }
        images.forEach { image in
            guard let rawImage = image.rawImage else { return }
            rawMetadata.addImage(rawImage)
        }
    }

    /// Creates metadata.
    ///
    /// - Parameters:
    ///   - title: The title of the content.
    ///   - metadataType: The type of the metadata.
    ///   - image: The associated image.
    ///
    /// The metadata type helps receivers adjust their layout according to the type of content being played.
    public init(
        title: String?,
        metadataType: GCKMediaMetadataType = .generic,
        image: CastImage?
    ) {
        if let image {
            self.init(title: title, metadataType: metadataType, images: [image])
        }
        else {
            self.init(title: title, metadataType: metadataType)
        }
    }

    /// The image URL that matches a set of hints.
    ///
    /// If no hints are provided, the first image is returned if available. To use hints, implement a `GCKUIImagePicker`
    /// and associate it with your `GCKCastContext`. For more information, see the
    /// [official documentation](https://developers.google.com/cast/docs/ios_sender/advanced#override_image_selection_and_caching).
    public func imageUrl(matching hints: CastImageHints? = nil) -> URL? {
        if let hints {
            return GCKCastContext.sharedInstance().imagePicker?.getImageWith(hints.rawImageHints, from: rawMetadata)?.url
        }
        else {
            return (rawMetadata.images().first as? GCKImage)?.url
        }
    }
}
