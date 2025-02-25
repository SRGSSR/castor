//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import GoogleCast

/// A cast player item.
public class CastPlayerItem: NSObject {
    public let id: GCKMediaQueueItemID

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
        else {
            return queue.item(withID: id)
        }
    }

    init(id: GCKMediaQueueItemID, queue: GCKMediaQueue) {
        self.id = id
        self.queue = queue
        super.init()
        queue.add(self)
    }

    // swiftlint:disable:next missing_docs
    public override func isEqual(_ object: Any?) -> Bool {
        (object as? Self)?.id == id
    }

    // swiftlint:disable:next missing_docs
    public override var hash: Int {
        Int(id)
    }
}

extension CastPlayerItem: GCKMediaQueueDelegate {
    public func mediaQueue(_ queue: GCKMediaQueue, didUpdateItemsAtIndexes indexes: [NSNumber]) {
        if let item = queue.item(withID: id, fetchIfNeeded: false) {
            cachedRawItem = item
        }
    }
}
