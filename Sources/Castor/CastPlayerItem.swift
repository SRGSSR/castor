//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import GoogleCast

/// A cast player item.
public struct CastPlayerItem: Identifiable {
    /// The id.
    public let id: GCKMediaQueueItemID

    let rawItem: GCKMediaQueueItem?

    /// The content title.
    public var title: String? {
        rawItem?.mediaInformation.metadata?.string(forKey: kGCKMetadataKeyTitle)
    }

    /// Creates an item from an asset and a metadata.
    ///
    /// - Parameters:
    ///   - asset: The asset.
    ///   - metadata: The metadata.
    public init(asset: Asset, metadata: CastMetadata) {
        self.id = kGCKMediaQueueInvalidItemID
        self.rawItem = Self.rawItem(from: asset, metadata: metadata)
    }

    init(id: GCKMediaQueueItemID, rawItem: GCKMediaQueueItem?) {
        self.id = id
        self.rawItem = rawItem
    }
}

private extension CastPlayerItem {
    static func rawItem(from asset: Asset, metadata: CastMetadata) -> GCKMediaQueueItem {
        let builder = GCKMediaQueueItemBuilder()
        builder.mediaInformation = Self.mediaInformation(from: asset, metadata: metadata)
        builder.autoplay = true
        return builder.build()
    }

    static func mediaInformation(from asset: Asset, metadata: CastMetadata) -> GCKMediaInformation {
        let builder = asset.mediaInformationBuilder()
        builder.metadata = metadata.rawMetadata
        return builder.build()
    }
}
