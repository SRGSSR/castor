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
    @Published public private(set) var items: [CastPlayerItem] = []

    init(remoteMediaClient: GCKRemoteMediaClient) {
        self.remoteMediaClient = remoteMediaClient
        super.init()
        remoteMediaClient.mediaQueue.add(self)
    }
}

extension CastQueue: GCKMediaQueueDelegate {
    // swiftlint:disable:next missing_docs
    public func mediaQueueDidReloadItems(_ queue: GCKMediaQueue) {
        items = (0..<queue.itemCount).map { index in
            CastPlayerItem(id: queue.itemID(at: index))
        }
    }

    // swiftlint:disable:next missing_docs
    public func mediaQueue(_ queue: GCKMediaQueue, didInsertItemsIn range: NSRange) {
        items.insert(
            contentsOf: (range.lowerBound..<range.upperBound)
                .map { index in
                    CastPlayerItem(id: queue.itemID(at: UInt(index)))
                },
            at: range.location
        )
    }

    // swiftlint:disable:next legacy_objc_type missing_docs
    public func mediaQueue(_ queue: GCKMediaQueue, didRemoveItemsAtIndexes indexes: [NSNumber]) {
        items.remove(atOffsets: IndexSet(indexes.map(\.intValue)))
    }
}
