//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import GoogleCast

extension GCKMediaQueue {
    func item(withID itemID: GCKMediaQueueItemID, fetchIfNeeded: Bool = true) -> GCKMediaQueueItem? {
        let index = indexOfItem(withID: itemID)
        return index != NSNotFound ? item(at: UInt(index), fetchIfNeeded: fetchIfNeeded) : nil
    }
}
