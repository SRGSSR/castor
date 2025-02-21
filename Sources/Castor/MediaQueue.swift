//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import GoogleCast

public final class MediaQueue: NSObject, ObservableObject {
    private let queue: GCKMediaQueue

    @Published public private(set) var items: [CastPlayerItem] = []

    init(from queue: GCKMediaQueue) {
        self.queue = queue
        super.init()
        queue.add(self)
    }
}

extension MediaQueue: GCKMediaQueueDelegate {
    // swiftlint:disable:next missing_docs
    public func mediaQueueWillChange(_ queue: GCKMediaQueue) {
        print("--> MQ will change, count = \(queue.itemCount), cached = \(queue.cachedItemCount), cacheSize = \(queue.cacheSize)")
    }

    // swiftlint:disable:next missing_docs
    public func mediaQueueDidReloadItems(_ queue: GCKMediaQueue) {
        print("--> MQ did reload, count = \(queue.itemCount), cached = \(queue.cachedItemCount), cacheSize = \(queue.cacheSize)")
    }

    // swiftlint:disable:next missing_docs
    public func mediaQueue(_ queue: GCKMediaQueue, didInsertItemsIn range: NSRange) {
        print("--> MQ did insert in \(range), count = \(queue.itemCount), cached = \(queue.cachedItemCount), cacheSize = \(queue.cacheSize)")
    }

    // swiftlint:disable:next missing_docs
    public func mediaQueue(_ queue: GCKMediaQueue, didUpdateItemsAtIndexes indexes: [NSNumber]) {
        print("--> MQ did update at \(indexes), count = \(queue.itemCount), cached = \(queue.cachedItemCount), cacheSize = \(queue.cacheSize)")
    }

    // swiftlint:disable:next missing_docs
    public func mediaQueue(_ queue: GCKMediaQueue, didRemoveItemsAtIndexes indexes: [NSNumber]) {
        print("--> MQ did remove at \(indexes), count = \(queue.itemCount), cached = \(queue.cachedItemCount), cacheSize = \(queue.cacheSize)")
    }

    // swiftlint:disable:next missing_docs
    public func mediaQueueDidChange(_ queue: GCKMediaQueue) {
        print("--> MQ did change, count = \(queue.itemCount), cached = \(queue.cachedItemCount), cacheSize = \(queue.cacheSize)")
        for i in 0..<queue.itemCount {
            print("--> MQ it at index \(i), id: \(queue.itemID(at: i)): \(queue.item(at: i, fetchIfNeeded: false))")
        }
    }
}
