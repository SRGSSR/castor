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
