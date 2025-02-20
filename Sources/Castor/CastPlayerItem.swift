//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import GoogleCast

/// A cast player item.
public struct CastPlayerItem: Hashable {
    private let rawItem: GCKMediaQueueItem

    /// The content title
    public var title: String? {
        rawItem.mediaInformation.metadata?.string(forKey: kGCKMetadataKeyTitle)
    }

    fileprivate init(rawItem: GCKMediaQueueItem) {
        self.rawItem = rawItem
    }

    // swiftlint:disable:next missing_docs
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.rawItem.itemID == rhs.rawItem.itemID
    }
}

extension GCKMediaQueueItem {
    func toCastPlayerItem() -> CastPlayerItem {
        .init(rawItem: self)
    }
}
