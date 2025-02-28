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

    @Published private var mediaStatus: GCKMediaStatus?

    /// The items in the queue.
    @Published public private(set) var items: [CastPlayerItem] = []

    private var currentItem: CastPlayerItem? {
        didSet {
            guard oldValue != currentItem else { return }
            if let itemID = currentItem?.id {
                jumpRequest.jump(to: itemID)
            }
        }
    }

    private var jumpRequest: JumpRequest

    init(remoteMediaClient: GCKRemoteMediaClient) {
        self.remoteMediaClient = remoteMediaClient
        jumpRequest = .init(remoteMediaClient: remoteMediaClient)
        mediaStatus = remoteMediaClient.mediaStatus
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
