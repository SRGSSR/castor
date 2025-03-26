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

    public func fetch(from queue: CastQueue) {
        queue.fetch(self)
    }

    public func metadata(from queue: CastQueue) -> CastMetadata? {
        queue.metadata(for: self)
    }
}
