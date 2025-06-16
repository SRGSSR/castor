//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import GoogleCast

final class ItemsRecipe: NSObject, @MainActor MutableReceiverStateRecipe {
    static let defaultValue: [CastPlayerItem] = []

    // FIXME: Remove "unowned" if the Google Cast SDK is updated to avoid the media queue strongly retaining its delegate.
    private unowned let service: GCKRemoteMediaClient       // Avoid cyclic reference due to the media queue delegate being retained.

    private let update: ([CastPlayerItem]) -> Void
    private var completion: ((Bool) -> Void)?

    private var items: [CastPlayerItem] {
        didSet {
            update(items)
        }
    }

    private var requests = 0 {
        didSet {
            guard requests == 0, oldValue != 0 else { return }
            items = items(items, merging: service.mediaQueue)
        }
    }

    init(service: GCKRemoteMediaClient, update: @escaping ([CastPlayerItem]) -> Void) {
        self.service = service
        self.update = update
        self.items = Self.status(from: service)
        super.init()
        service.mediaQueue.add(self)        // The delegate is retained.
    }

    static func status(from service: GCKRemoteMediaClient) -> [CastPlayerItem] {
        service.mediaQueue.itemIDs().map { .init(id: $0, queue: service.mediaQueue) }
    }

    func requestUpdate(to value: [CastPlayerItem], completion: @escaping (Bool) -> Void) -> Bool {
        guard service.canMakeRequest() else { return false }
        self.completion = completion

        let previousIds = items.map(\.idNumber)
        let currentIds = value.map(\.idNumber)

        requests += 2

        let removedIds = Array(Set(previousIds).subtracting(currentIds))
        let removeRequest = service.queueRemoveItems(withIDs: removedIds)
        removeRequest.delegate = self

        let reorderRequest = service.queueReorderItems(
            withIDs: currentIds,
            insertBeforeItemWithID: kGCKMediaQueueInvalidItemID
        )
        reorderRequest.delegate = self
        return true
    }
}

extension ItemsRecipe: GCKMediaQueueDelegate {
    func mediaQueueDidReloadItems(_ queue: GCKMediaQueue) {
        items = items(items, merging: queue)
    }

    func mediaQueue(_ queue: GCKMediaQueue, didInsertItemsIn range: NSRange) {
        items.insert(
            contentsOf: (range.lowerBound..<range.upperBound)
                .map { index in
                    CastPlayerItem(id: queue.itemID(at: UInt(index)), queue: queue)
                },
            at: range.location
        )
    }

    // swiftlint:disable:next legacy_objc_type
    func mediaQueue(_ queue: GCKMediaQueue, didRemoveItemsAtIndexes indexes: [NSNumber]) {
        items.remove(atOffsets: IndexSet(indexes.map(\.intValue)))
    }
}

extension ItemsRecipe: GCKRequestDelegate {
    func requestDidComplete(_ request: GCKRequest) {
        if requests == 1 {
            completion?(true)
        }
        requests -= 1
    }

    func request(_ request: GCKRequest, didAbortWith abortReason: GCKRequestAbortReason) {
        if requests == 1 {
            completion?(false)
        }
        requests -= 1
    }

    func request(_ request: GCKRequest, didFailWithError error: GCKError) {
        if requests == 1 {
            completion?(false)
        }
        requests -= 1
    }
}

private extension ItemsRecipe {
    func items(_ items: [CastPlayerItem], merging queue: GCKMediaQueue) -> [CastPlayerItem] {
        var updatedItems = items
        queue.itemIDs().difference(from: items.map(\.id)).inferringMoves().forEach { change in
            switch change {
            case let .insert(offset: offset, element: element, associatedWith: associatedWith):
                if let associatedWith {
                    updatedItems.insert(items[associatedWith], at: offset)
                }
                else {
                    updatedItems.insert(.init(id: element, queue: queue), at: offset)
                }
            case let .remove(offset: offset, element: _, associatedWith: _):
                updatedItems.remove(at: offset)
            }
        }
        return updatedItems
    }
}
