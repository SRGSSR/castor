//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import GoogleCast

/// An image associated with an item.
public struct CastImage {
    let rawImage: GCKImage?
    
    /// Creates an image
    ///
    /// - Parameters:
    ///   - url: The URL at which the image can be downloaded.
    ///   - size: The image size (if known).
    public init(url: URL, size: CGSize = .zero) {
        rawImage = .init(url: url, width: Int(size.width), height: Int(size.height))
    }
}
