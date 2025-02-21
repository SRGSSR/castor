//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import GoogleCast

/// A cast player item.
public struct CastPlayerItem: Hashable {
    let id: GCKMediaQueueItemID
    let rawItem: GCKMediaQueueItem?

    /// The content title.
    public var title: String? {
        rawItem?.mediaInformation.metadata?.string(forKey: kGCKMetadataKeyTitle)
    }

    /// Return `true` if item metadata has been loaded
    public var isLoaded: Bool {
        rawItem != nil
    }

    fileprivate init(id: GCKMediaQueueItemID, rawItem: GCKMediaQueueItem?) {
        self.id = id
        self.rawItem = rawItem
    }

    static func loadingItem(withId id: GCKMediaQueueItemID) -> Self {
        .init(id: id, rawItem: nil)
    }

    // swiftlint:disable:next missing_docs
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
}

extension GCKMediaQueueItem {
    func toCastPlayerItem() -> CastPlayerItem {
        .init(id: itemID, rawItem: self)
    }
}
