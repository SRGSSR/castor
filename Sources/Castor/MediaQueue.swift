//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import GoogleCast
import SwiftUI

/// A queue managing player items.
public final class MediaQueue: NSObject, ObservableObject {
    private let remoteMediaClient: GCKRemoteMediaClient

    private var cachedItems: [CastCachedPlayerItem] = []

    /// The items in the queue.
    @Published public private(set) var items: [CastPlayerItem] = []

    init(remoteMediaClient: GCKRemoteMediaClient) {
        self.remoteMediaClient = remoteMediaClient
        super.init()
        remoteMediaClient.mediaQueue.add(self)
    }

    /// Try to load a `CastPlayerItem` from the cache.
    ///
    /// - Parameter item: The item to load from the cache.
    public func load(_ item: CastPlayerItem) {
        guard let cachedItem = cachedItems.first(where: { $0.id == item.id }) else { return }
        cachedItem.load()
    }
}

extension MediaQueue: GCKMediaQueueDelegate {
    // swiftlint:disable:next missing_docs
    public func mediaQueueDidReloadItems(_ queue: GCKMediaQueue) {
        cachedItems = (0..<queue.itemCount).map { index in
            CastCachedPlayerItem(id: queue.itemID(at: index), queue: queue)
        }
    }

    // swiftlint:disable:next missing_docs
    public func mediaQueue(_ queue: GCKMediaQueue, didInsertItemsIn range: NSRange) {
        cachedItems.insert(
            contentsOf: (range.lowerBound..<range.upperBound)
                .map { index in
                    CastCachedPlayerItem(id: queue.itemID(at: UInt(index)), queue: queue)
                },
            at: range.location
        )
    }

    // swiftlint:disable:next legacy_objc_type missing_docs
    public func mediaQueue(_ queue: GCKMediaQueue, didRemoveItemsAtIndexes indexes: [NSNumber]) {
        cachedItems.remove(atOffsets: IndexSet(indexes.map(\.intValue)))
    }

    // swiftlint:disable:next missing_docs
    public func mediaQueueDidChange(_ queue: GCKMediaQueue) {
        items = cachedItems.map { $0.toItem() }
    }
}
