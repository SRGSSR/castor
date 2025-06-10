//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import GoogleCast

/// A delegate wrapper that always leaks a small amount of memory but avoids issues with `GCKMediaQueue` retaining
/// its delegate.
final class MediaQueueDelegate: NSObject {
    private weak var wrapped: GCKMediaQueueDelegate?

    init(wrapped: GCKMediaQueueDelegate?, queue: GCKMediaQueue) {
        self.wrapped = wrapped
        super.init()
        queue.add(self)         // The delegate is retained
    }
}

extension MediaQueueDelegate: GCKMediaQueueDelegate {
    func mediaQueueWillChange(_ queue: GCKMediaQueue) {
        wrapped?.mediaQueueWillChange?(queue)
    }

    func mediaQueueDidReloadItems(_ queue: GCKMediaQueue) {
        wrapped?.mediaQueueDidReloadItems?(queue)
    }

    func mediaQueue(_ queue: GCKMediaQueue, didInsertItemsIn range: NSRange) {
        wrapped?.mediaQueue?(queue, didInsertItemsIn: range)
    }

    func mediaQueue(_ queue: GCKMediaQueue, didRemoveItemsAtIndexes indexes: [NSNumber]) {
        wrapped?.mediaQueue?(queue, didRemoveItemsAtIndexes: indexes)
    }

    func mediaQueue(_ queue: GCKMediaQueue, didUpdateItemsAtIndexes indexes: [NSNumber]) {
        wrapped?.mediaQueue?(queue, didUpdateItemsAtIndexes: indexes)
    }

    func mediaQueueDidChange(_ queue: GCKMediaQueue) {
        wrapped?.mediaQueueDidChange?(queue)
    }
}
