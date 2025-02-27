//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import GoogleCast

/// A cast player item.
public class CastPlayerItem: NSObject {
    let id: GCKMediaQueueItemID

    private let queue: GCKMediaQueue
    private var cachedRawItem: GCKMediaQueueItem?

    /// The content title.
    public var title: String? {
        rawItem?.mediaInformation.metadata?.string(forKey: kGCKMetadataKeyTitle)
    }

    private var rawItem: GCKMediaQueueItem? {
        if let cachedRawItem {
            return cachedRawItem
        }
        else if let item = queue.item(withID: id, fetchIfNeeded: false) {
            cachedRawItem = item
            return item
        }
        else {
            return queue.item(withID: id)
        }
    }

    override public var hash: Int {
        Int(id)
    }

    init(id: GCKMediaQueueItemID, queue: GCKMediaQueue) {
        self.id = id
        self.queue = queue
        super.init()
        queue.add(self)
    }

    override public func isEqual(_ object: Any?) -> Bool {
        (object as? Self)?.id == id
    }
}

extension CastPlayerItem: GCKMediaQueueDelegate {
    // swiftlint:disable:next legacy_objc_type missing_docs
    public func mediaQueue(_ queue: GCKMediaQueue, didUpdateItemsAtIndexes indexes: [NSNumber]) {
        if let item = queue.item(withID: id, fetchIfNeeded: false) {
            cachedRawItem = item
        }
    }
}
