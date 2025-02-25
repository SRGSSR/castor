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
    public func mediaQueueDidReloadItems(_ queue: GCKMediaQueue) {
        items = (0..<queue.itemCount).map { index in
            CastPlayerItem(id: queue.itemID(at: index), rawItem: queue.item(at: index))
        }
        print("--> MQ did reload, count = \(queue.itemCount), cached = \(queue.cachedItemCount), cacheSize = \(queue.cacheSize)")
    }

    // swiftlint:disable:next missing_docs
    public func mediaQueue(_ queue: GCKMediaQueue, didInsertItemsIn range: NSRange) {
        items.insert(
            contentsOf: (range.lowerBound..<range.upperBound)
                .map { index in
                    CastPlayerItem(id: queue.itemID(at: UInt(index)), rawItem: queue.item(at: UInt(index)))
                },
            at: range.location
        )
        print("--> MQ did insert in \(range), count = \(queue.itemCount), cached = \(queue.cachedItemCount), cacheSize = \(queue.cacheSize)")
    }

    // swiftlint:disable:next missing_docs
    public func mediaQueue(_ queue: GCKMediaQueue, didUpdateItemsAtIndexes indexes: [NSNumber]) {
        indexes.map(\.intValue).forEach { index in
            items[index] = .init(id: queue.itemID(at: UInt(index)), rawItem: queue.item(at: UInt(index), fetchIfNeeded: false))
        }
        print("--> MQ did update at \(indexes), count = \(queue.itemCount), cached = \(queue.cachedItemCount), cacheSize = \(queue.cacheSize)")
    }

    // swiftlint:disable:next missing_docs
    public func mediaQueue(_ queue: GCKMediaQueue, didRemoveItemsAtIndexes indexes: [NSNumber]) {
        items.remove(atOffsets: IndexSet(indexes.map(\.intValue)))
        print("--> MQ did remove at \(indexes), count = \(queue.itemCount), cached = \(queue.cachedItemCount), cacheSize = \(queue.cacheSize)")
    }

    public func mediaQueueDidChange(_ queue: GCKMediaQueue) {
        printQueue(queue)
    }

    private func printQueue(_ queue: GCKMediaQueue) {
        for i in 0..<queue.itemCount {
            print("--> MQ it at index \(i), id: \(queue.itemID(at: i)): \(queue.item(at: i, fetchIfNeeded: false))")
        }
    }
}
