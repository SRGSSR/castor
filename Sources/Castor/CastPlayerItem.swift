//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import GoogleCast

/// A cast player item.
public struct CastPlayerItem {
    let rawItem: GCKMediaQueueItem

    fileprivate init(rawItem: GCKMediaQueueItem) {
        self.rawItem = rawItem
    }
}

extension GCKMediaQueueItem {
    func toCastPlayerItem() -> CastPlayerItem {
        .init(rawItem: self)
    }
}
