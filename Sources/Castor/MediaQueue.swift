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
            currentCachedItem = Self.currentItem(for: remoteMediaClient.mediaStatus, queue: remoteMediaClient.mediaQueue)
        }
    }

    private var cachedItems: [CastCachedPlayerItem] = []

    /// The items in the queue.
    @Published public private(set) var items: [CastPlayerItem] = []

    private weak var request: GCKRequest?

    private var currentCachedItem: CastCachedPlayerItem? {
        didSet {
            guard request == nil, oldValue != currentCachedItem, let currentCachedItem else { return }
            request = remoteMediaClient.queueJumpToItem(withID: currentCachedItem.id)
            request?.delegate = self
        }
    }

    init(remoteMediaClient: GCKRemoteMediaClient) {
        self.remoteMediaClient = remoteMediaClient
        mediaStatus = remoteMediaClient.mediaStatus
        currentCachedItem = Self.currentItem(for: remoteMediaClient.mediaStatus, queue: remoteMediaClient.mediaQueue)
        super.init()
        remoteMediaClient.add(self)
        remoteMediaClient.mediaQueue.add(self)
    }

    private static func currentItem(for mediaStatus: GCKMediaStatus?, queue: GCKMediaQueue) -> CastCachedPlayerItem? {
        guard let rawItem = mediaStatus?.currentQueueItem else { return nil }
        return CastCachedPlayerItem(id: rawItem.itemID, queue: queue)
    }

    /// Current item.
    public func item() -> Binding<CastPlayerItem?> {
        .init { [weak self] in
            self?.currentCachedItem?.toItem()
        } set: { [weak self] newValue in
            if let self, let newValue {
                currentCachedItem = .init(id: newValue.id, queue: remoteMediaClient.mediaQueue)
            }
        }
    }

    /// Try to load a `CastPlayerItem` from the cache.
    ///
    /// - Parameter item: The item to load from the cache.
    public func load(_ item: CastPlayerItem) {
        guard let cachedItem = cachedItems.first(where: { $0.id == item.id }) else { return }
        cachedItem.load()
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
        cachedItems = (0..<queue.itemCount).map { index in
            CastCachedPlayerItem(id: queue.itemID(at: index), queue: queue)
        }
    }

    // swiftlint:disable:next missing_docs
    public func mediaQueue(_ queue: GCKMediaQueue, didInsertItemsIn range: NSRange) {
        cachedItems.insert(
            contentsOf: (range.lowerBound..<range.upperBound)
                .map { index in
                    CastCachedPlayerItem(id: queue.itemID(at: UInt(index)), queue: queue)
                },
            at: range.location
        )
    }

    // swiftlint:disable:next legacy_objc_type missing_docs
    public func mediaQueue(_ queue: GCKMediaQueue, didRemoveItemsAtIndexes indexes: [NSNumber]) {
        cachedItems.remove(atOffsets: IndexSet(indexes.map(\.intValue)))
    }

    // swiftlint:disable:next missing_docs
    public func mediaQueueDidChange(_ queue: GCKMediaQueue) {
        items = cachedItems.map { $0.toItem() }
    }
}

extension MediaQueue: GCKRequestDelegate {
    // swiftlint:disable:next missing_docs
    public func requestDidComplete(_ request: GCKRequest) {
        if let itemID = currentCachedItem?.id, itemID != remoteMediaClient.mediaStatus?.currentItemID {
            self.request = remoteMediaClient.queueJumpToItem(withID: itemID)
            self.request?.delegate = self
        }
    }
}
