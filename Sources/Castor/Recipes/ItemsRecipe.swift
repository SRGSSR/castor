//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import GoogleCast

final class ItemsRecipe: NSObject, MutableSynchronizerRecipe {
    static let defaultValue: [CastPlayerItem] = []

    private weak var service: GCKRemoteMediaClient?

    // swiftlint:disable:next discouraged_optional_collection
    private let update: ([CastPlayerItem]?) -> Void
    private let completion: (Bool) -> Void

    private var items: [CastPlayerItem] = [] {
        didSet {
            update(items)
        }
    }

    private var requests = 0 {
        didSet {
            guard requests == 0, oldValue != 0 else { return }
            items = items(items, merging: service?.mediaQueue)
        }
    }

    private var isRequesting: Bool {
        requests != 0
    }

    // swiftlint:disable:next discouraged_optional_collection
    init(service: GCKRemoteMediaClient, update: @escaping ([CastPlayerItem]?) -> Void, completion: @escaping (Bool) -> Void) {
        self.service = service
        self.update = update
        self.completion = completion
        super.init()
        service.mediaQueue.add(self)
    }

    // swiftlint:disable:next discouraged_optional_collection
    static func status(from service: GCKRemoteMediaClient) -> [CastPlayerItem]? {
        service.mediaQueue.itemIDs().map { .init(id: $0, queue: service.mediaQueue) }
    }

    func makeRequest(for value: [CastPlayerItem]) -> Bool {
        guard let service, service.canMakeRequest() else { return false }

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
            completion(true)
        }
        requests -= 1
    }

    func request(_ request: GCKRequest, didAbortWith abortReason: GCKRequestAbortReason) {
        if requests == 1 {
            completion(false)
        }
        requests -= 1
    }

    func request(_ request: GCKRequest, didFailWithError error: GCKError) {
        if requests == 1 {
            completion(false)
        }
        requests -= 1
    }
}

private extension ItemsRecipe {
    func items(_ items: [CastPlayerItem], merging queue: GCKMediaQueue?) -> [CastPlayerItem] {
        guard let queue else { return items }
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
