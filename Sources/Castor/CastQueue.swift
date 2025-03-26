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

    /// The items in the queue.
    @Published public var items: [CastPlayerItem] = [] {
        didSet {
            guard canRequest else { return }
            requestUpdates(from: oldValue, to: items)
        }
    }

    /// The current item.
    ///
    /// Stops playback if set to `nil`.
    ///
    /// > Important: On iOS 18.3 and below use `currentItemSelection` to manage selection in a `List`.
    public var currentItem: CastPlayerItem? {
        didSet {
            if let currentItem {
                guard currentItem != oldValue else { return }
                current.jump(to: currentItem.id)
            }
            else {
                remoteMediaClient.stop()
            }
        }
    }

    private var publishedCurrentItem: CastPlayerItem? {
        get {
            currentItem
        }
        set {
            currentItem = newValue
            objectWillChange.send()
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
    private let current: CastCurrent

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

    private var requests: Set<GCKRequestID> = [] {
        didSet {
            guard !oldValue.isEmpty, requests.isEmpty else { return }
            nonRequestedItems = Self.items(from: remoteMediaClient.mediaQueue)
        }
    }

    private var isRequesting: Bool {
        !requests.isEmpty
    }

    init(remoteMediaClient: GCKRemoteMediaClient) {
        self.remoteMediaClient = remoteMediaClient
        self.current = .init(remoteMediaClient: remoteMediaClient)
        super.init()
        self.current.delegate = self
        remoteMediaClient.mediaQueue.add(self)
    }
}

public extension CastQueue {
    /// A Boolean indicating if the queue is empty.
    var isEmpty: Bool {
        items.isEmpty
    }

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

    /// Moves an item after another one.
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
        publishedCurrentItem = items[previousIndex]
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
        publishedCurrentItem = items[nextIndex]
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
    static func items(from queue: GCKMediaQueue) -> [CastPlayerItem] {
        (0..<queue.itemCount).map { index in
            CastPlayerItem(id: queue.itemID(at: index))
        }
    }

    func requestUpdates(from previousItems: [CastPlayerItem], to currentItems: [CastPlayerItem]) {
        Mutation.mutations(from: previousItems, to: currentItems).forEach { mutation in
            switch mutation {
            case let .move(element, before):
                let request = remoteMediaClient.queueMoveItem(
                    withID: element.id,
                    beforeItemWithID: before?.id ?? kGCKMediaQueueInvalidItemID
                )
                requests.insert(request.requestID)
                request.delegate = self
            case let .remove(element):
                let request = remoteMediaClient.queueRemoveItem(withID: element.id)
                requests.insert(request.requestID)
                request.delegate = self
            }
        }
    }
}

extension CastQueue: CastCurrentDelegate {
    func didUpdate(item: CastPlayerItem?) {
        publishedCurrentItem = item
    }
}

extension CastQueue: GCKMediaQueueDelegate {
    // swiftlint:disable:next missing_docs
    public func mediaQueueDidReloadItems(_ queue: GCKMediaQueue) {
        guard !isRequesting else { return }
        nonRequestedItems = Self.items(from: queue)
    }

    // swiftlint:disable:next missing_docs
    public func mediaQueue(_ queue: GCKMediaQueue, didInsertItemsIn range: NSRange) {
        guard !isRequesting else { return }
        nonRequestedItems.insert(
            contentsOf: (range.lowerBound..<range.upperBound)
                .map { index in
                    CastPlayerItem(id: queue.itemID(at: UInt(index)))
                },
            at: range.location
        )
    }

    // swiftlint:disable:next legacy_objc_type missing_docs
    public func mediaQueue(_ queue: GCKMediaQueue, didRemoveItemsAtIndexes indexes: [NSNumber]) {
        guard !isRequesting else { return }
        nonRequestedItems.remove(atOffsets: IndexSet(indexes.map(\.intValue)))
    }
}

extension CastQueue: GCKRequestDelegate {
    // swiftlint:disable:next missing_docs
    public func requestDidComplete(_ request: GCKRequest) {
        requests.remove(request.requestID)
    }

    // swiftlint:disable:next missing_docs
    public func request(_ request: GCKRequest, didAbortWith abortReason: GCKRequestAbortReason) {
        requests.remove(request.requestID)
    }

    // swiftlint:disable:next missing_docs
    public func request(_ request: GCKRequest, didFailWithError error: GCKError) {
        requests.remove(request.requestID)
    }
}
