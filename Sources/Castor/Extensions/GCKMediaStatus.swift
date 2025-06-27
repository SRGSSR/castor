//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import GoogleCast

extension GCKMediaStatus {
    var isConnected: Bool {
        queueItemCount != 0
    }

    func items() -> [GCKMediaQueueItem] {
        (0..<queueItemCount).compactMap { queueItem(at: $0) }
    }

    func currentIndex() -> Int? {
        let items = items()
        guard !items.isEmpty else { return nil }
        return items.firstIndex { $0.itemID == currentItemID }
    }
}
