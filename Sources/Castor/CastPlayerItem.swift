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

    init(id: GCKMediaQueueItemID) {
        self.id = id
    }

    /// Asynchronously fetches an item from the specified queue.
    ///
    /// - Parameter queue: The queue to retrieve metadata from.
    ///
    /// Fetching an item from a queue to which it does not belong leads to unexpected behavior.
    public func fetch(from queue: CastQueue) {
        queue.fetch(self)
    }

    /// Reads item metadata from the specified queue.
    ///
    /// - Parameter queue: The queue to retrieve metadata from.
    ///
    /// Reading metadata for an item from a queue to which it does not belong leads to unexpected behavior. Metadata
    /// must be fetched first by calling ``fetchMetadata(from:)``.
    public func metadata(from queue: CastQueue) -> CastMetadata? {
        guard let rawItem = queue.rawItem(for: self) else { return nil }
        return .init(rawMetadata: rawItem.mediaInformation.metadata)
    }
}
