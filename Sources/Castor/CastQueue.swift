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
    private var rawItemCache: [GCKMediaQueueItemID: GCKMediaQueueItem] = [:]

    private var currentItemId: GCKMediaQueueItemID? {
        get {
            currentItemSynchronizer.currentItemId
        }
        set {
            currentItemSynchronizer.currentItemId = newValue
            updateCurrentItem()
        }
    }

    /// The items in the queue.
    ///
    /// > Warning: Avoid making significant changes to the item list by mutating this property, as each change will
    ///   be performed asynchronously on the receiver.
    @Published public var items: [CastPlayerItem] = [] {
        didSet {
            updateCurrentItem()
            guard canRequest else { return }
            requestUpdates(from: oldValue, to: items)
        }
    }

    /// A Boolean indicating if the queue is empty.
    public var isEmpty: Bool {
        items.isEmpty
    }

    /// The current item.
    ///
    /// Stops playback if set to `nil`.
    ///
    /// > Important: On iOS 18.3 and below use `currentItemSelection` to manage selection in a `List`.
    public var currentItem: CastPlayerItem? {
        get {
            // FIXME: Should likely consolidate items/current id and store the current result, not calculate it every time
            items.first { $0.id == currentItemId }
        }
        set {
            guard canJump else { return }
            currentItemSynchronizer.currentItemId = newValue?.id
        }
    }

    /// A binding to the current item, for use as `List` selection.
    @available(iOS, introduced: 16.0, deprecated: 18.4, message: "Use currentItem instead")
    public var currentItemSelection: Binding<CastPlayerItem?> {
        .init { [weak self] in
            self?.currentItem
        } set: { [weak self] item in
            guard let self, let item else { return }
            currentItem = item
        }
    }

    private var canRequest = true
    private var canJump = true

    private let currentItemSynchronizer: CurrentItemSynchronizer

    private var nonRequestedItems: [CastPlayerItem] {
        get {
            items
        }
        set {
            canRequest = false
            items = newValue
            canRequest = true
        }
    }

    private var requests = 0 {
        didSet {
            guard requests == 0, oldValue != 0 else { return }
            nonRequestedItems = items(items, merging: remoteMediaClient.mediaQueue)
        }
    }

    private var isRequesting: Bool {
        requests != 0
    }

    init(remoteMediaClient: GCKRemoteMediaClient) {
        self.remoteMediaClient = remoteMediaClient
        self.currentItemSynchronizer = .init(remoteMediaClient: remoteMediaClient)
        super.init()
        self.currentItemSynchronizer.delegate = self
        remoteMediaClient.mediaQueue.add(self)          // The delegate is retained
    }

    func release() {
        remoteMediaClient.mediaQueue.remove(self)
    }
}

public extension CastQueue {
    /// Removes an item from the queue.
    ///
    /// - Parameter item: The item to remove.
    func remove(_ item: CastPlayerItem) {
        items.removeAll { $0 == item }
    }

    /// Removes all items from the queue.
    func removeAllItems() {
        items.removeAll()
    }
}

public extension CastQueue {
    /// Moves an item before another one.
    ///
    /// - Parameters:
    ///   - item: The item to move. The method does nothing if the item does not belong to the queue.
    ///   - beforeItem: The item before which the moved item must be relocated. Pass `nil` to move the item to the
    ///     front of the queue. If the item does not belong to the queue the method does nothing.
    /// - Returns: `true` iff the item could be moved.
    @discardableResult
    func move(_ item: CastPlayerItem, before beforeItem: CastPlayerItem?) -> Bool {
        guard canMove(item, before: beforeItem), let movedIndex = items.firstIndex(of: item) else {
            return false
        }
        if let beforeItem {
            guard let index = items.firstIndex(of: beforeItem) else { return false }
            items.move(from: movedIndex, to: index)
        }
        else {
            items.move(from: movedIndex, to: items.startIndex)
        }
        return true
    }

    /// Moves an item before another one.
    ///
    /// - Parameters:
    ///   - item: The item to move.
    ///   - afterItem: The item after which the moved item must be relocated. Pass `nil` to move the item to the
    ///     back of the queue. If the item does not belong to the queue the method does nothing.
    /// - Returns: `true` iff the item could be moved.
    @discardableResult
    func move(_ item: CastPlayerItem, after afterItem: CastPlayerItem?) -> Bool {
        guard canMove(item, after: afterItem), let movedIndex = items.firstIndex(of: item) else {
            return false
        }
        if let afterItem {
            guard let index = items.firstIndex(of: afterItem) else { return false }
            items.move(from: movedIndex, to: items.index(after: index))
        }
        else {
            items.move(from: movedIndex, to: items.endIndex)
        }
        return true
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
        self.currentItem = items[nextIndex]
    }
}

extension CastQueue {
    func fetch(_ item: CastPlayerItem) {
        guard rawItem(for: item) == nil else { return }
        remoteMediaClient.mediaQueue.item(withID: item.id)
    }

    func rawItem(for item: CastPlayerItem) -> GCKMediaQueueItem? {
        if let rawItem = rawItemCache[item.id] {
            return rawItem
        }
        else if let rawItem = remoteMediaClient.mediaQueue.item(withID: item.id, fetchIfNeeded: false) {
            rawItemCache[item.id] = rawItem
            return rawItem
        }
        else {
            return nil
        }
    }
}

private extension CastQueue {
    func canMove(_ item: CastPlayerItem, before beforeItem: CastPlayerItem?) -> Bool {
        guard items.contains(item) else { return false }
        if let beforeItem {
            guard item != beforeItem, let index = items.firstIndex(of: beforeItem) else { return false }
            guard index > 0 else { return true }
            return items[items.index(before: index)] != item
        }
        else {
            return items.first != item
        }
    }

    func canMove(_ item: CastPlayerItem, after afterItem: CastPlayerItem?) -> Bool {
        guard items.contains(item) else { return false }
        if let afterItem {
            guard item != afterItem, let index = items.firstIndex(of: afterItem) else { return false }
            guard index < items.count - 1 else { return true }
            return items[items.index(after: index)] != item
        }
        else {
            return items.last != item
        }
    }
}

private extension CastQueue {
    func updateCurrentItem() {
        canJump = false
        currentItem = items.first { $0.id == currentItemId }
        canJump = true
    }

    func items(_ items: [CastPlayerItem], merging queue: GCKMediaQueue) -> [CastPlayerItem] {
        var updatedItems = items
        queue.itemIDs().difference(from: items.map(\.id)).inferringMoves().forEach { change in
            switch change {
            case let .insert(offset: offset, element: element, associatedWith: associatedWith):
                if let associatedWith {
                    updatedItems.insert(items[associatedWith], at: offset)
                }
                else {
                    updatedItems.insert(.init(id: element, queue: self), at: offset)
                }
            case let .remove(offset: offset, element: _, associatedWith: _):
                updatedItems.remove(at: offset)
            }
        }
        return updatedItems
    }
}

private extension CastQueue {
    static func index(after item: CastPlayerItem, in items: [CastPlayerItem]) -> Int? {
        guard let itemIndex = items.firstIndex(of: item) else { return nil }
        let nextIndex = items.index(after: itemIndex)
        return (nextIndex < items.endIndex) ? nextIndex : nil
    }

    static func index(before item: CastPlayerItem, in items: [CastPlayerItem]) -> Int? {
        guard let itemIndex = items.firstIndex(of: item), itemIndex > items.startIndex else {
            return nil
        }
        return items.index(before: itemIndex)
    }
}

private extension CastQueue {
    func requestUpdates(from previousItems: [CastPlayerItem], to currentItems: [CastPlayerItem]) {
        // Workaround for Google Cast SDK state consistency possibly arising when removing items from a sender while
        // updating them from another one.
        guard !currentItems.isEmpty else {
            remoteMediaClient.stop()
            return
        }

        let previousIds = previousItems.map(\.idNumber)
        let currentIds = currentItems.map(\.idNumber)

        requests += 2

        let removedIds = Array(Set(previousIds).subtracting(currentIds))
        let removeRequest = remoteMediaClient.queueRemoveItems(withIDs: removedIds)
        removeRequest.delegate = self

        let reorderRequest = remoteMediaClient.queueReorderItems(
            withIDs: currentIds,
            insertBeforeItemWithID: kGCKMediaQueueInvalidItemID
        )
        reorderRequest.delegate = self
    }
}

extension CastQueue: ChangeDelegate {
    func didChange() {
        objectWillChange.send()
    }
}

extension CastQueue: GCKMediaQueueDelegate {
    // swiftlint:disable:next missing_docs
    public func mediaQueueDidReloadItems(_ queue: GCKMediaQueue) {
        guard !isRequesting else { return }
        nonRequestedItems = items(items, merging: queue)
    }

    // swiftlint:disable:next missing_docs
    public func mediaQueue(_ queue: GCKMediaQueue, didInsertItemsIn range: NSRange) {
        guard !isRequesting else { return }
        nonRequestedItems.insert(
            contentsOf: (range.lowerBound..<range.upperBound)
                .map { index in
                    CastPlayerItem(id: queue.itemID(at: UInt(index)), queue: self)
                },
            at: range.location
        )
    }

    // swiftlint:disable:next legacy_objc_type missing_docs
    public func mediaQueue(_ queue: GCKMediaQueue, didRemoveItemsAtIndexes indexes: [NSNumber]) {
        guard !isRequesting else { return }
        nonRequestedItems.remove(atOffsets: IndexSet(indexes.map(\.intValue)))
    }

    // swiftlint:disable:next legacy_objc_type missing_docs
    public func mediaQueue(_ queue: GCKMediaQueue, didUpdateItemsAtIndexes indexes: [NSNumber]) {
        let ids = itemIds(atIndexes: indexes)
        items.forEach { item in
            guard ids.contains(item.id) else { return }
            item.notifyUpdate()
        }
    }

    // swiftlint:disable:next legacy_objc_type
    private func itemIds(atIndexes indexes: [NSNumber]) -> [GCKMediaQueueItemID] {
        indexes.map { index in
            remoteMediaClient.mediaQueue.itemID(at: UInt(truncating: index))
        }
    }
}

extension CastQueue: GCKRequestDelegate {
    // swiftlint:disable:next missing_docs
    public func requestDidComplete(_ request: GCKRequest) {
        requests -= 1
    }

    // swiftlint:disable:next missing_docs
    public func request(_ request: GCKRequest, didAbortWith abortReason: GCKRequestAbortReason) {
        requests -= 1
    }

    // swiftlint:disable:next missing_docs
    public func request(_ request: GCKRequest, didFailWithError error: GCKError) {
        requests -= 1
    }
}
