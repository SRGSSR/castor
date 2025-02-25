//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import GoogleCast
import SwiftUI

public final class MediaQueue: NSObject, ObservableObject {
    private let remoteMediaClient: GCKRemoteMediaClient

    @Published private var mediaStatus: GCKMediaStatus? {
        didSet {
            // TODO: Should likely use ID to locate existing local item before creating a new one
            if let item = mediaStatus?.currentQueueItem, request == nil {
                currentItem = CastPlayerItem(id: item.itemID, queue: remoteMediaClient.mediaQueue)
            }
        }
    }

    @Published public private(set) var items: [CastPlayerItem] = []

    private weak var request: GCKRequest?

    private var currentItem: CastPlayerItem? {
        didSet {
            guard oldValue != currentItem, let currentItem else { return }
            if let request, request.inProgress {
                return
            }
            else {
                request = remoteMediaClient.queueJumpToItem(withID: currentItem.id)
                request?.delegate = self
            }
        }
    }

    init(remoteMediaClient: GCKRemoteMediaClient) {
        self.remoteMediaClient = remoteMediaClient
        mediaStatus = remoteMediaClient.mediaStatus
        super.init()
        remoteMediaClient.add(self)
        remoteMediaClient.mediaQueue.add(self)
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

    // swiftlint:disable:next missing_docs
    public func mediaQueue(_ queue: GCKMediaQueue, didRemoveItemsAtIndexes indexes: [NSNumber]) {
        items.remove(atOffsets: IndexSet(indexes.map(\.intValue)))
    }

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

