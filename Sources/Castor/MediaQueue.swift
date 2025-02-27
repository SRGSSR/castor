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

    @Published private var mediaStatus: GCKMediaStatus? {
        didSet {
            guard request == nil else { return }
            currentItem = Self.currentItem(for: remoteMediaClient.mediaStatus, queue: remoteMediaClient.mediaQueue)
        }
    }

    /// The items in the queue.
    @Published public private(set) var items: [CastPlayerItem] = []

    private weak var request: GCKRequest?

    private var currentItem: CastPlayerItem? {
        didSet {
            guard request == nil, oldValue != currentItem, let currentItem else { return }
            request = remoteMediaClient.queueJumpToItem(withID: currentItem.id)
            request?.delegate = self
        }
    }

    init(remoteMediaClient: GCKRemoteMediaClient) {
        self.remoteMediaClient = remoteMediaClient
        mediaStatus = remoteMediaClient.mediaStatus
        currentItem = Self.currentItem(for: remoteMediaClient.mediaStatus, queue: remoteMediaClient.mediaQueue)
        super.init()
        remoteMediaClient.add(self)
        remoteMediaClient.mediaQueue.add(self)
    }

    private static func currentItem(for mediaStatus: GCKMediaStatus?, queue: GCKMediaQueue) -> CastPlayerItem? {
        guard let rawItem = mediaStatus?.currentQueueItem else { return nil }
        return CastPlayerItem(id: rawItem.itemID, queue: queue)
    }

    /// Current item.
    public func item() -> Binding<CastPlayerItem?> {
        .init {
            self.currentItem
        } set: { newValue in
            self.currentItem = newValue
        }
    }

    /// Inserts an item before another one.
    ///
    /// - Parameters:
    ///   - item: The item to insert.
    ///   - beforeItem: The item before which insertion must take place. Pass `nil` to insert the item at the front
    ///     of the queue.
    /// - Returns: `true` iff the item could be inserted.
    @discardableResult
    public func insert(_ item: CastPlayerItem, before beforeItem: CastPlayerItem?) -> Bool {
        false
    }

    /// Insert items before another one.
    ///
    /// - Parameters:
    ///   - items: The items to insert.
    ///   - beforeItem: The item before which insertion must take place. Pass `nil` to insert the items at the front
    ///     of the queue.
    /// - Returns: `true` iff the items could be inserted.
    @discardableResult
    public func insert(_ items: [CastPlayerItem], before beforeItem: CastPlayerItem?) -> Bool {
        false
    }

    /// Inserts an item after another one.
    ///
    /// - Parameters:
    ///   - item: The item to insert.
    ///   - afterItem: The item after which insertion must take place. Pass `nil` to insert the item at the back of
    ///     the queue. If this item does not exist the method does nothing.
    /// - Returns: `true` iff the item could be inserted.
    @discardableResult
    public func insert(_ item: CastPlayerItem, after afterItem: CastPlayerItem?) -> Bool {
        false
    }

    /// Inserts items after another one.
    ///
    /// - Parameters:
    ///   - items: The items to insert.
    ///   - afterItem: The item after which insertion must take place. Pass `nil` to insert the items at the back of
    ///     the queue. If this item does not exist the method does nothing.
    /// - Returns: `true` iff the items could be inserted.
    @discardableResult
    public func insert(_ items: [CastPlayerItem], after afterItem: CastPlayerItem?) -> Bool {
        false
    }

    /// Prepends an item to the queue.
    ///
    /// - Parameter item: The item to prepend.
    /// - Returns: `true` iff the item could be prepended.
    @discardableResult
    func prepend(_ item: CastPlayerItem) -> Bool {
        false
    }

    /// Prepends items to the queue.
    ///
    /// - Parameter items: The items to prepend.
    /// - Returns: `true` iff the items could be prepended.
    @discardableResult
    func prepend(_ items: [CastPlayerItem]) -> Bool {
        false
    }

    /// Appends an item to the queue.
    ///
    /// - Parameter item: The item to append.
    /// - Returns: `true` iff the item could be appended.
    @discardableResult
    func append(_ item: CastPlayerItem) -> Bool {
        false
    }

    /// Appends items to the queue.
    ///
    /// - Parameter items: The items to append.
    /// - Returns: `true` iff the items could be appended.
    @discardableResult
    func append(_ items: [CastPlayerItem]) -> Bool {
        false
    }

    /// Moves an item before another one.
    ///
    /// - Parameters:
    ///   - item: The item to move. The method does nothing if the item does not belong to the queue.
    ///   - beforeItem: The item before which the moved item must be relocated. Pass `nil` to move the item to the
    ///     front of the queue. If the item does not belong to the queue the method does nothing.
    /// - Returns: `true` iff the item could be moved.
    @discardableResult
    func move(_ item: CastPlayerItem, before beforeItem: CastPlayerItem?) -> Bool {
        false
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
        false
    }

    /// Removes an item from the queue.
    ///
    /// - Parameter item: The item to remove.
    func remove(_ item: CastPlayerItem) {
    }

    /// Removes all items from the queue.
    func removeAllItems() {
    }
}

extension MediaQueue: GCKRemoteMediaClientListener {
    // swiftlint:disable:next missing_docs
    public func remoteMediaClient(_ client: GCKRemoteMediaClient, didUpdate mediaStatus: GCKMediaStatus?) {
        self.mediaStatus = mediaStatus
    }
}

extension MediaQueue: GCKMediaQueueDelegate {
    // swiftlint:disable:next missing_docs
    public func mediaQueueDidReloadItems(_ queue: GCKMediaQueue) {
        items = (0..<queue.itemCount).map { index in
            CastPlayerItem(id: queue.itemID(at: index), queue: queue)
        }
    }

    // swiftlint:disable:next missing_docs
    public func mediaQueue(_ queue: GCKMediaQueue, didInsertItemsIn range: NSRange) {
        items.insert(
            contentsOf: (range.lowerBound..<range.upperBound)
                .map { index in
                    CastPlayerItem(id: queue.itemID(at: UInt(index)), queue: queue)
                },
            at: range.location
        )
    }

    // swiftlint:disable:next legacy_objc_type missing_docs
    public func mediaQueue(_ queue: GCKMediaQueue, didRemoveItemsAtIndexes indexes: [NSNumber]) {
        items.remove(atOffsets: IndexSet(indexes.map(\.intValue)))
    }

    // swiftlint:disable:next missing_docs
    public func mediaQueueDidChange(_ queue: GCKMediaQueue) {
        objectWillChange.send()
    }
}

extension MediaQueue: GCKRequestDelegate {
    // swiftlint:disable:next missing_docs
    public func requestDidComplete(_ request: GCKRequest) {
        if let itemID = currentItem?.id, itemID != remoteMediaClient.mediaStatus?.currentItemID {
            self.request = remoteMediaClient.queueJumpToItem(withID: itemID)
            self.request?.delegate = self
        }
    }
}
