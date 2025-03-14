//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import GoogleCast

final class CastCachedPlayerItem: NSObject {
    let id: GCKMediaQueueItemID
    let queue: GCKMediaQueue
    private var rawItem: GCKMediaQueueItem?

    init(id: GCKMediaQueueItemID, queue: GCKMediaQueue) {
        self.id = id
        self.queue = queue
        super.init()
        queue.add(self)
    }

    func fetch() {
        guard rawItem == nil else { return }
        rawItem = queue.item(withID: id, fetchIfNeeded: false) ?? queue.item(withID: id)
    }

    func toItem() -> CastPlayerItem {
        .init(id: id, rawItem: rawItem)
    }
}

extension CastCachedPlayerItem: GCKMediaQueueDelegate {
    // swiftlint:disable:next legacy_objc_type
    func mediaQueue(_ queue: GCKMediaQueue, didUpdateItemsAtIndexes indexes: [NSNumber]) {
        if let item = queue.item(withID: id, fetchIfNeeded: false) {
            rawItem = item
        }
    }
}
