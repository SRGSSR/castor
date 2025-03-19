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

    private var isSynchronizing = false

    /// The items in the queue.
    @Published public var items: [CastPlayerItem] = [] {
        didSet {
            guard !isSynchronizing else { return }
            let changes = items.difference(from: oldValue).inferringMoves()
            changes.forEach { change in
                switch change {
                case let .insert(offset: offset, element: element, associatedWith: associatedWith):
                    if let associatedWith {
                        let offsetID = remoteMediaClient.mediaQueue.itemID(at: UInt(offset))
                        let elementID = element.id
                        let associatedID = remoteMediaClient.mediaQueue.itemID(at: UInt(associatedWith))
                        print("--> insert: offset = \(offset), elementID = \(elementID), associated = \(associatedWith)")
                        print("    --> insert: offsetID = \(offsetID), elementID = \(elementID), associatedID = \(associatedID)")
                        // Nothing to be done here
                    }
                    else {
                        // Should never happen
                    }
                case let .remove(offset: offset, element: element, associatedWith: associatedWith):
                    if let associatedWith {
                        let offsetID = remoteMediaClient.mediaQueue.itemID(at: UInt(offset))
                        let elementID = element.id
                        let associatedID = remoteMediaClient.mediaQueue.itemID(at: UInt(associatedWith))
                        let nextAssociatedID = remoteMediaClient.mediaQueue.itemID(at: UInt(associatedWith + 1))
                        print("--> remove: offset = \(offset), elementID = \(elementID), associated = \(associatedWith)")
                        print("    --> remove: offsetID = \(offsetID), elementID = \(elementID), associatedID = \(associatedID), nextAssociatedID = \(nextAssociatedID)")
                        if offset > associatedWith {
                            remoteMediaClient.queueMoveItem(withID: elementID, beforeItemWithID: associatedID)
                        }
                        else {
                            remoteMediaClient.queueMoveItem(withID: elementID, beforeItemWithID: nextAssociatedID)
                        }
                    }
                    else {
                        remoteMediaClient.queueRemoveItem(withID: element.id)
                    }
                }
            }
        }
    }

    /// The current item.
    @Published public private(set) var currentItem: CastPlayerItem?

    init(remoteMediaClient: GCKRemoteMediaClient) {
        self.remoteMediaClient = remoteMediaClient
        super.init()
        remoteMediaClient.mediaQueue.add(self)
    }
}

extension CastQueue: GCKMediaQueueDelegate {
    // swiftlint:disable:next missing_docs
    public func mediaQueueDidReloadItems(_ queue: GCKMediaQueue) {
        isSynchronizing = true
        defer {
            isSynchronizing = false
        }
        items = (0..<queue.itemCount).map { index in
            CastPlayerItem(id: queue.itemID(at: index))
        }
    }

    // swiftlint:disable:next missing_docs
    public func mediaQueue(_ queue: GCKMediaQueue, didInsertItemsIn range: NSRange) {
        isSynchronizing = true
        defer {
            isSynchronizing = false
        }
        items.insert(
            contentsOf: (range.lowerBound..<range.upperBound)
                .map { index in
                    CastPlayerItem(id: queue.itemID(at: UInt(index)))
                },
            at: range.location
        )
    }

    // swiftlint:disable:next legacy_objc_type missing_docs
    public func mediaQueue(_ queue: GCKMediaQueue, didRemoveItemsAtIndexes indexes: [NSNumber]) {
        isSynchronizing = true
        defer {
            isSynchronizing = false
        }
        items.remove(atOffsets: IndexSet(indexes.map(\.intValue)))
    }
}

extension CastQueue {
    static func index(after item: CastPlayerItem, in items: [CastPlayerItem]) -> Int? {
        guard let itemIndex = items.firstIndex(where: { $0.id == item.id }) else { return nil }
        let nextIndex = items.index(after: itemIndex)
        return (nextIndex < items.endIndex) ? nextIndex : nil
    }

    static func index(before item: CastPlayerItem, in items: [CastPlayerItem]) -> Int? {
        guard let itemIndex = items.firstIndex(where: { $0.id == item.id }), itemIndex > items.startIndex else {
            return nil
        }
        return items.index(before: itemIndex)
    }
}

extension CastQueue {
    func fetch(_ item: CastPlayerItem) {

    }

    func jump(to itemId: GCKMediaQueueItemID) {

    }
}

public extension CastQueue {
    /// Loads player items and starts playback.
    /// 
    /// - Parameter items: Items to load.
    func load(items: [CastPlayerItem]) {
        // remoteMediaClient.queueLoad(items.compactMap(\.rawItem), with: .init())
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
            if let nextIndex = Self.index(after: afterItem, in: items) {
                remoteMediaClient.queueInsert(rawItems, beforeItemWithID: items[nextIndex].id)
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
        []
//        items.filter { item in
//            !self.items.contains { $0.id == item.id }
//        }
//        .compactMap(\.rawItem)
    }
}

public extension CastQueue {
    /// Removes items from the queue.
    ///
    /// - Parameter items: The items to remove.
    func remove(_ items: [CastPlayerItem]) {
        // swiftlint:disable:next legacy_objc_type
        let ids = items.map { NSNumber(value: $0.id) }
        remoteMediaClient.queueRemoveItems(withIDs: ids)
    }

    /// Removes all items from the queue.
    func removeAllItems() {
        remove(items)
    }
}

public extension CastQueue {
    /// Checks whether returning to the previous item in the queue is possible.
    ///
    /// - Returns: `true` if possible.
    func canReturnToPreviousItem() -> Bool {
        !items.isEmpty && currentItem?.id != items.first?.id
    }

    /// Returns to the previous item in the queue.
    func returnToPreviousItem() {
        guard canReturnToPreviousItem(), let currentItem, let previousIndex = Self.index(before: currentItem, in: items) else { return }
        jump(to: items[previousIndex].id)
        self.currentItem = items[previousIndex]
    }

    /// Checks whether moving to the next item in the queue is possible.
    ///
    /// - Returns: `true` if possible.
    func canAdvanceToNextItem() -> Bool {
        !items.isEmpty && currentItem?.id != items.last?.id
    }

    /// Moves to the next item in the queue.
    func advanceToNextItem() {
        guard canAdvanceToNextItem(), let currentItem, let nextIndex = Self.index(after: currentItem, in: items) else { return }
        jump(to: items[nextIndex].id)
        self.currentItem = items[nextIndex]
    }
}
