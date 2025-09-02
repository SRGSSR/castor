//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import GoogleCast

/// A player item for Cast playback.
public final class CastPlayerItem: ObservableObject {
    /// The identifier.
    public let id: GCKMediaQueueItemID

    @LazyItem private var rawItem: GCKMediaQueueItem?

    // swiftlint:disable:next legacy_objc_type
    var idNumber: NSNumber {
        .init(value: id)
    }

    /// A Boolean value indicating whether the item has been fetched.
    public var isFetched: Bool {
        rawItem != nil
    }

    /// The asset associated with the item.
    ///
    /// Must be retrieved by calling `fetch()`, for example when a view displaying the item appears.
    public var asset: CastAsset? {
        .init(rawMediaInformation: rawItem?.mediaInformation)
    }

    init(id: GCKMediaQueueItemID, queue: GCKMediaQueue) {
        self.id = id
        _rawItem = .init(id: id, queue: queue)
    }

    /// Fetches the complete information for the item from the receiver.
    public func fetch() {
        _rawItem.fetch()
    }
}

extension CastPlayerItem: Hashable {
    // swiftlint:disable:next missing_docs
    public static func == (lhs: CastPlayerItem, rhs: CastPlayerItem) -> Bool {
        lhs.id == rhs.id
    }

    // swiftlint:disable:next missing_docs
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
