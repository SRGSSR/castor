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
    private let current: CastCurrent

    private var cachedItems: [CastCachedPlayerItem] = []

    /// The items in the queue.
    @Published public private(set) var items: [CastPlayerItem] = []

    /// The current item.
    @Published public private(set) var currentItem: CastPlayerItem?

    init(remoteMediaClient: GCKRemoteMediaClient) {
        self.remoteMediaClient = remoteMediaClient
        self.current = .init(remoteMediaClient: remoteMediaClient)
        super.init()
        self.current.delegate = self
        remoteMediaClient.mediaQueue.add(self)
    }

    /// Loads player items and starts playback.
    /// - Parameter items: Items to load.
    public func load(items: [CastPlayerItem]) {
        remoteMediaClient.queueLoad(items.compactMap(\.rawItem), with: .init())
    }

    /// Inserts an item before another one.
    ///
    /// - Parameters:
    ///   - item: The item to insert.
    ///   - beforeItem: The item before which insertion must take place. Pass `nil` to insert the item at the front
    ///     of the queue.
    ///
    /// Does nothing if the item already belongs to the queue.
    public func insert(_ item: CastPlayerItem, before beforeItem: CastPlayerItem?) {
        guard let item = item.rawItem else { return }
        remoteMediaClient.queueInsert([item], beforeItemWithID: beforeItem?.id ?? items.first?.id ?? kGCKMediaQueueInvalidItemID)
    }

    /// Inserts an item after another one.
    ///
    /// - Parameters:
    ///   - item: The item to insert.
    ///   - afterItem: The item after which insertion must take place. Pass `nil` to insert the item at the back of
    ///     the queue. If this item does not exist the method does nothing.
    /// - Returns: `true` iff the item could be inserted.
    ///
    /// Does nothing if the item already belongs to the queue.
    public func insert(_ item: CastPlayerItem, after afterItem: CastPlayerItem?) {
        guard let item = item.rawItem else { return }
        if let afterItemIndex = items.firstIndex(where: { $0.id == afterItem?.id }) {
            let nextItemIndex = items.index(after: afterItemIndex)
            if nextItemIndex < items.endIndex {
                let nextItem = items[nextItemIndex]
                remoteMediaClient.queueInsert([item], beforeItemWithID: nextItem.id)
            }
            else {
                remoteMediaClient.queueInsert([item], beforeItemWithID: kGCKMediaQueueInvalidItemID)
            }
        }
    }

    /// Move to the associated item.
    ///
    /// - Parameter item: The item to move to.
    public func jump(to item: CastPlayerItem) {
        jump(to: item.id)
    }

    func fetch(_ item: CastPlayerItem) {
        guard let cachedItem = cachedItems.first(where: { $0.id == item.id }) else { return }
        cachedItem.fetch()
    }

    func jump(to itemId: CastPlayerItem.ID) {
        guard currentItem?.id != itemId else { return }
        current.jump(to: itemId)
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

extension MediaQueue: CastCurrentDelegate {
    func didUpdate(item: CastPlayerItem?) {
        currentItem = item
    }
}
