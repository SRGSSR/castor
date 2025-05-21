//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import GoogleCast
import SwiftUI

final class ItemsSynchronizer: NSObject, ObservableObject {
    private let remoteMediaClient: GCKRemoteMediaClient
    weak var delegate: ChangeDelegate?

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
    @Published var items: [CastPlayerItem] = [] {
        didSet {
            updateCurrentItem()
            guard canRequest else { return }
            requestUpdates(from: oldValue, to: items)
        }
    }

    /// The current item.
    ///
    /// Stops playback if set to `nil`.
    ///
    /// > Important: On iOS 18.3 and below use `currentItemSelection` to manage selection in a `List`.
    var currentItem: CastPlayerItem? {
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
    var currentItemSelection: Binding<CastPlayerItem?> {
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

extension ItemsSynchronizer {
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

private extension ItemsSynchronizer {
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

private extension ItemsSynchronizer {
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

extension ItemsSynchronizer: ChangeDelegate {
    func didChange() {
        objectWillChange.send()
    }
}

extension ItemsSynchronizer: GCKMediaQueueDelegate {
    // swiftlint:disable:next missing_docs
    func mediaQueueDidReloadItems(_ queue: GCKMediaQueue) {
        guard !isRequesting else { return }
        nonRequestedItems = items(items, merging: queue)
    }

    // swiftlint:disable:next missing_docs
    func mediaQueue(_ queue: GCKMediaQueue, didInsertItemsIn range: NSRange) {
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
    func mediaQueue(_ queue: GCKMediaQueue, didRemoveItemsAtIndexes indexes: [NSNumber]) {
        guard !isRequesting else { return }
        nonRequestedItems.remove(atOffsets: IndexSet(indexes.map(\.intValue)))
    }

    // swiftlint:disable:next legacy_objc_type missing_docs
    func mediaQueue(_ queue: GCKMediaQueue, didUpdateItemsAtIndexes indexes: [NSNumber]) {
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

extension ItemsSynchronizer: GCKRequestDelegate {
    // swiftlint:disable:next missing_docs
    func requestDidComplete(_ request: GCKRequest) {
        requests -= 1
    }

    // swiftlint:disable:next missing_docs
    func request(_ request: GCKRequest, didAbortWith abortReason: GCKRequestAbortReason) {
        requests -= 1
    }

    // swiftlint:disable:next missing_docs
    func request(_ request: GCKRequest, didFailWithError error: GCKError) {
        requests -= 1
    }
}
