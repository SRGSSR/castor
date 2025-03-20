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

    private var canRequest = true

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
        super.init()
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

private extension CastQueue {
    static func items(from queue: GCKMediaQueue) -> [CastPlayerItem] {
        (0..<queue.itemCount).map { index in
            CastPlayerItem(id: queue.itemID(at: index))
        }
    }

    func requestUpdates(from previousItems: [CastPlayerItem], to currentItems: [CastPlayerItem]) {
        let changes = currentItems.difference(from: previousItems).inferringMoves()
        changes.forEach { change in
            switch change {
            case .insert:
                break
            case let .remove(offset: offset, element: element, associatedWith: associatedWith):
                if let associatedWith {
                    let beforeIndex = (offset > associatedWith) ? associatedWith : associatedWith + 1
                    let beforeId = remoteMediaClient.mediaQueue.itemID(at: UInt(beforeIndex))
                    let request = remoteMediaClient.queueMoveItem(withID: element.id, beforeItemWithID: beforeId)
                    requests.insert(request.requestID)
                    request.delegate = self
                }
                else {
                    let request = remoteMediaClient.queueRemoveItem(withID: element.id)
                    requests.insert(request.requestID)
                    request.delegate = self
                }
            }
        }
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
