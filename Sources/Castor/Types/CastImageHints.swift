//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import GoogleCast

/// Hints provided to a `GCKUIImagePicker` about the type and size of an image to be selected.
public struct CastImageHints {
    let rawImageHints: GCKUIImageHints

    /// Creates hints.
    ///
    /// - Parameters:
    ///   - type: The type of the image.
    ///   - size: The size of the image.
    public init(type: GCKMediaMetadataImageType, size: CGSize = .zero) {
        rawImageHints = .init(imageType: type, imageSize: size)
    }
}
