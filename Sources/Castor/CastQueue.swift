//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import GoogleCast
import SwiftUI

/// A queue managing player items.
public final class CastQueue: NSObject, ObservableObject {
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
}

extension CastQueue: GCKMediaQueueDelegate {
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

extension CastQueue: CastCurrentDelegate {
    func didUpdate(item: CastPlayerItem?) {
        currentItem = item
    }
}

extension CastQueue {
    func fetch(_ item: CastPlayerItem) {
        guard let cachedItem = cachedItems.first(where: { $0.id == item.id }) else { return }
        cachedItem.fetch()
    }

    func jump(to itemId: CastPlayerItem.ID) {
        guard currentItem?.id != itemId else { return }
        current.jump(to: itemId)
    }
}

public extension CastQueue {
    /// Loads player items and starts playback.
    /// 
    /// - Parameter items: Items to load.
    func load(items: [CastPlayerItem]) {
        remoteMediaClient.queueLoad(items.compactMap(\.rawItem), with: .init())
    }

    /// Move to the associated item.
    ///
    /// - Parameter item: The item to move to.
    func jump(to item: CastPlayerItem) {
        jump(to: item.id)
    }
}

public extension CastQueue {
    /// Inserts items before another one.
    ///
    /// - Parameters:
    ///   - insertedItems: The items to insert.
    ///   - beforeItem: The item before which insertion must take place. Pass `nil` to insert the items at the front
    ///     of the queue.
    /// - Returns: `true` iff some items could be inserted.
    ///
    /// Ignores items already belonging to the queue.
    @discardableResult
    func insert(_ insertedItems: [CastPlayerItem], before beforeItem: CastPlayerItem?) -> Bool {
        let rawItems = insertableRawItem(from: insertedItems)
        guard !rawItems.isEmpty else { return false }
        if let beforeItem {
            guard items.contains(where: { $0.id == beforeItem.id }) else { return false }
            remoteMediaClient.queueInsert(rawItems, beforeItemWithID: beforeItem.id)
        }
        else if let firstItem = items.first {
            remoteMediaClient.queueInsert(rawItems, beforeItemWithID: firstItem.id)
        }
        else {
            remoteMediaClient.queueInsert(rawItems, beforeItemWithID: kGCKMediaQueueInvalidItemID)
        }
        return true
    }

    /// Inserts items after another one.
    ///
    /// - Parameters:
    ///   - insertedItems: The items to insert.
    ///   - afterItem: The item after which insertion must take place. Pass `nil` to insert the items at the back of
    ///     the queue. If this item does not exist the method does nothing.
    /// - Returns: `true` iff some items could be inserted.
    ///
    /// Ignores items already belonging to the queue.
    @discardableResult
    func insert(_ insertedItems: [CastPlayerItem], after afterItem: CastPlayerItem?) -> Bool {
        let rawItems = insertableRawItem(from: insertedItems)
        guard !rawItems.isEmpty else { return false }
        if let afterItem {
            guard let afterItemIndex = items.firstIndex(where: { $0.id == afterItem.id }) else { return false }
            let nextItemIndex = items.index(after: afterItemIndex)
            if nextItemIndex < items.endIndex {
                remoteMediaClient.queueInsert(rawItems, beforeItemWithID: items[nextItemIndex].id)
            }
            else {
                remoteMediaClient.queueInsert(rawItems, beforeItemWithID: kGCKMediaQueueInvalidItemID)
            }
        }
        else {
            remoteMediaClient.queueInsert(rawItems, beforeItemWithID: kGCKMediaQueueInvalidItemID)
        }
        return true
    }

    /// Prepends items to the queue.
    ///
    /// - Parameter items: The items to prepend.
    /// - Returns: `true` iff the items could be prepended.
    @discardableResult
    func prepend(_ items: [CastPlayerItem]) -> Bool {
        insert(items, before: nil)
    }

    /// Appends items to the queue.
    ///
    /// - Parameter items: The items to append.
    /// - Returns: `true` iff the items could be appended.
    @discardableResult
    func append(_ items: [CastPlayerItem]) -> Bool {
        insert(items, after: nil)
    }

    private func insertableRawItem(from items: [CastPlayerItem]) -> [GCKMediaQueueItem] {
        items.filter { item in
            !self.items.contains { $0.id == item.id }
        }
        .compactMap(\.rawItem)
    }
}

public extension CastQueue {
    /// Removes items from the queue.
    ///
    /// - Parameter items: The items to remove.
    func remove(_ items: [CastPlayerItem]) {
        // swiftlint:disable:next legacy_objc_type
        remoteMediaClient.queueRemoveItems(withIDs: items.map { NSNumber(value: $0.id) })
    }

    /// Removes all items from the queue.
    func removeAllItems() {
        remove(items)
    }
}
