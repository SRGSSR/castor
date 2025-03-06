//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import GoogleCast

/// A cast player item.
public struct CastPlayerItem: Hashable {
    let id: GCKMediaQueueItemID

    /// The content title.
    public let title: String?

    init(id: GCKMediaQueueItemID, rawItem: GCKMediaQueueItem?) {
        self.id = id
        self.title = rawItem?.mediaInformation.metadata?.string(forKey: kGCKMetadataKeyTitle)
    }
}
