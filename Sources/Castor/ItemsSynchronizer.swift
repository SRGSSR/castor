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

    func updateItems(_ items: [CastPlayerItem]) {
        // TODO: - Maybe requestUpdates can be called before setting the items.
        //       - Maybe add a guard checking if there is at least a change.
        //       - Maybe self.items = items is not needed anymore (no immediate sync required here)
        let oldItems = self.items
        self.items = items
        requestUpdates(from: oldItems, to: items)
    }

    private(set) var items: [CastPlayerItem] = []

    private var requests = 0 {
        didSet {
            guard requests == 0, oldValue != 0 else { return }
            items = items(items, merging: remoteMediaClient.mediaQueue)
            delegate?.didChange()
        }
    }

    private var isRequesting: Bool {
        requests != 0
    }

    init(remoteMediaClient: GCKRemoteMediaClient) {
        self.remoteMediaClient = remoteMediaClient
        super.init()
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

extension ItemsSynchronizer: GCKMediaQueueDelegate {
    func mediaQueueDidReloadItems(_ queue: GCKMediaQueue) {
        guard !isRequesting else { return }
        items = items(items, merging: queue)
    }

    func mediaQueue(_ queue: GCKMediaQueue, didInsertItemsIn range: NSRange) {
        guard !isRequesting else { return }
        items.insert(
            contentsOf: (range.lowerBound..<range.upperBound)
                .map { index in
                    CastPlayerItem(id: queue.itemID(at: UInt(index)), queue: self)
                },
            at: range.location
        )
    }

    // swiftlint:disable:next legacy_objc_type
    func mediaQueue(_ queue: GCKMediaQueue, didRemoveItemsAtIndexes indexes: [NSNumber]) {
        guard !isRequesting else { return }
        items.remove(atOffsets: IndexSet(indexes.map(\.intValue)))
    }

    // swiftlint:disable:next legacy_objc_type
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
    func requestDidComplete(_ request: GCKRequest) {
        requests -= 1
    }

    func request(_ request: GCKRequest, didAbortWith abortReason: GCKRequestAbortReason) {
        requests -= 1
    }

    func request(_ request: GCKRequest, didFailWithError error: GCKError) {
        requests -= 1
    }
}
