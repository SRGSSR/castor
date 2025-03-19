//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import GoogleCast

/// A cast player item.
public struct CastPlayerItem: Hashable {
    /// The id.
    public let id: GCKMediaQueueItemID

    /// The content title.
    public var title: String? {
        "\(id)"
    }

    /// Creates an item from an asset and metadata.
    ///
    /// - Parameters:
    ///   - asset: The asset.
    ///   - metadata: The metadata.
    public init(asset: CastAsset, metadata: CastMetadata) {
        self.id = kGCKMediaQueueInvalidItemID
    }

    init(id: GCKMediaQueueItemID) {
        self.id = id
    }
}
