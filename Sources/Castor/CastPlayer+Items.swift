//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import GoogleCast

public extension CastPlayer {
    private static func rawItems(from assets: [CastAsset]) -> [GCKMediaQueueItem] {
        assets.map { $0.rawItem() }
    }

    /// Loads player items from assets and starts playback.
    ///
    /// - Parameter assets: The assets for the items to load.
    func loadItems(from assets: [CastAsset]) {
        remoteMediaClient.queueLoad(Self.rawItems(from: assets), with: .init())
    }

    /// Loads the player item from an asset and starts playback.
    ///
    /// - Parameter asset: The assets for the item to load.
    func loadItem(from asset: CastAsset) {
        loadItems(from: [asset])
    }

    /// Inserts items before another one.
    ///
    /// - Parameters:
    ///   - assets: The assets for the items to insert.
    ///   - beforeItem: The item before which insertion must take place. Pass `nil` to insert the items at the front
    ///     of the queue.
    @discardableResult
    func insertItems(from assets: [CastAsset], before beforeItem: CastPlayerItem?) -> Bool {
        if let beforeItem {
            guard items.contains(beforeItem) else { return false }
            remoteMediaClient.queueInsert(Self.rawItems(from: assets), beforeItemWithID: beforeItem.id)
        }
        else {
            prependItems(from: assets)
        }
        return true
    }

    /// Inserts items after another one.
    ///
    /// - Parameters:
    ///   - assets: The assets for the items to insert.
    ///   - afterItem: The item after which insertion must take place. Pass `nil` to insert the items at the back
    ///     of the queue.
    @discardableResult
    func insertItems(from assets: [CastAsset], after afterItem: CastPlayerItem?) -> Bool {
        if let afterItem {
            guard let afterItemIndex = items.firstIndex(of: afterItem) else { return false }
            let nextItem = items[safeIndex: items.index(after: afterItemIndex)]
            remoteMediaClient.queueInsert(Self.rawItems(from: assets), beforeItemWithID: nextItem?.id ?? kGCKMediaQueueInvalidItemID)
        }
        else {
            appendItems(from: assets)
        }
        return true
    }

    /// Inserts an item after another one.
    ///
    /// - Parameters:
    ///   - asset: The asset for the item to insert.
    ///   - afterItem: The item after which insertion must take place. Pass `nil` to insert the item at the back
    ///     of the queue.
    @discardableResult
    func insertItem(from asset: CastAsset, after afterItem: CastPlayerItem?) -> Bool {
        insertItems(from: [asset], after: afterItem)
    }

    /// Insert an item before another one.
    ///
    /// - Parameters:
    ///   - asset: The asset for the item to insert.
    ///   - beforeItem: The item before which insertion must take place. Pass `nil` to insert the item at the front
    ///     of the queue.
    @discardableResult
    func insertItem(from asset: CastAsset, before beforeItem: CastPlayerItem?) -> Bool {
        insertItems(from: [asset], before: beforeItem)
    }

    /// Prepends items to the queue.
    ///
    /// - Parameter assets: The assets for the items to insert.
    func appendItems(from assets: [CastAsset]) {
        if !items.isEmpty {
            remoteMediaClient.queueInsert(Self.rawItems(from: assets), beforeItemWithID: kGCKMediaQueueInvalidItemID)
        }
        else {
            loadItems(from: assets)
        }
    }

    /// Prepends an item to the queue.
    ///
    /// - Parameter asset: The asset for the item to insert.
    func appendItem(from asset: CastAsset) {
        appendItems(from: [asset])
    }

    /// Prepends items to the queue.
    ///
    /// - Parameter assets: The assets for the items to prepend.
    func prependItems(from assets: [CastAsset]) {
        if let firstItem = items.first {
            remoteMediaClient.queueInsert(Self.rawItems(from: assets), beforeItemWithID: firstItem.id)
        }
        else {
            loadItems(from: assets)
        }
    }

    /// Prepends an item to the queue.
    ///
    /// - Parameter asset: The asset for the item to prepend.
    func prependItem(from asset: CastAsset) {
        prependItems(from: [asset])
    }
}
