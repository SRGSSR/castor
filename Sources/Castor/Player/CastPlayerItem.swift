//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import GoogleCast

/// A cast player item.
public final class CastPlayerItem: ObservableObject {
    /// The id.
    public let id: GCKMediaQueueItemID

    @LazyItem private var rawItem: GCKMediaQueueItem?

    // swiftlint:disable:next legacy_objc_type
    var idNumber: NSNumber {
        .init(value: id)
    }

    /// A Boolean indicating whether the item has been fetched.
    public var isFetched: Bool {
        rawItem != nil
    }

    /// The metadata associated with the item.
    ///
    /// Metadata must be retrieved by calling `fetch()`, for example on appearance of a view displaying the item.
    public var metadata: CastMetadata? {
        guard let rawItem else { return nil }
        return .init(rawMetadata: rawItem.mediaInformation.metadata)
    }

    init(id: GCKMediaQueueItemID, queue: GCKMediaQueue) {
        self.id = id
        _rawItem = .init(id: id, queue: queue)
    }

    /// Fetch complete item information from the receiver.
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
