//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import GoogleCast

/// Hints provided to a `GCKUIImagePicker` regarding the type and size of the image to be selected.
public struct CastImageHints {
    let rawImageHints: GCKUIImageHints

    /// Creates image selection hints.
    ///
    /// - Parameters:
    ///   - type: The type of the image.
    ///   - size: The size of the image.
    public init(type: GCKMediaMetadataImageType, size: CGSize = .zero) {
        rawImageHints = .init(imageType: type, imageSize: size)
    }
}
