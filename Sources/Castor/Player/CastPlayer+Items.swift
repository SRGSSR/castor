//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import GoogleCast
import SwiftUI

public extension CastPlayer {
    /// The items queued by the player.
    var items: [CastPlayerItem] {
        get {
            _items
        }
        set {
            _items = newValue
        }
    }

    private static func rawItems(from assets: [CastAsset]) -> [GCKMediaQueueItem] {
        assets.map { $0.rawItem() }
    }

    /// Loads player items from assets and starts playback.
    ///
    /// - Parameters:
    ///   - assets: The assets for the item to load.
    ///   - options: The loading options.
    func loadItems(from assets: [CastAsset], with options: CastLoadOptions = .init()) {
        isLoading = true
        remoteMediaClient.queueLoad(Self.rawItems(from: assets), with: options.rawOptions)
    }

    /// Loads the player item from an asset and starts playback.
    ///
    /// - Parameters:
    ///   - asset: The asset for the item to load.
    ///   - options: The loading options.
    func loadItem(from asset: CastAsset, with options: CastLoadOptions = .init()) {
        loadItems(from: [asset], with: options)
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

public extension CastPlayer {
    /// Removes an item from the queue.
    ///
    /// - Parameter item: The item to remove.
    func remove(_ item: CastPlayerItem) {
        items.removeAll { $0 == item }
    }

    /// Removes all items from the queue.
    func removeAllItems() {
        items.removeAll()
    }
}

public extension CastPlayer {
    /// Moves an item before another one.
    ///
    /// - Parameters:
    ///   - item: The item to move. The method does nothing if the item does not belong to the queue.
    ///   - beforeItem: The item before which the moved item must be relocated. Pass `nil` to move the item to the
    ///     front of the queue. If the item does not belong to the queue the method does nothing.
    /// - Returns: `true` iff the item could be moved.
    @discardableResult
    func move(_ item: CastPlayerItem, before beforeItem: CastPlayerItem?) -> Bool {
        guard canMove(item, before: beforeItem), let movedIndex = items.firstIndex(of: item) else {
            return false
        }
        if let beforeItem {
            guard let index = items.firstIndex(of: beforeItem) else { return false }
            items.move(from: movedIndex, to: index)
        }
        else {
            items.move(from: movedIndex, to: items.startIndex)
        }
        return true
    }

    /// Moves an item before another one.
    ///
    /// - Parameters:
    ///   - item: The item to move.
    ///   - afterItem: The item after which the moved item must be relocated. Pass `nil` to move the item to the
    ///     back of the queue. If the item does not belong to the queue the method does nothing.
    /// - Returns: `true` iff the item could be moved.
    @discardableResult
    func move(_ item: CastPlayerItem, after afterItem: CastPlayerItem?) -> Bool {
        guard canMove(item, after: afterItem), let movedIndex = items.firstIndex(of: item) else {
            return false
        }
        if let afterItem {
            guard let index = items.firstIndex(of: afterItem) else { return false }
            items.move(from: movedIndex, to: items.index(after: index))
        }
        else {
            items.move(from: movedIndex, to: items.endIndex)
        }
        return true
    }
}

private extension CastPlayer {
    func canMove(_ item: CastPlayerItem, before beforeItem: CastPlayerItem?) -> Bool {
        guard items.contains(item) else { return false }
        if let beforeItem {
            guard item != beforeItem, let index = items.firstIndex(of: beforeItem) else { return false }
            guard index > 0 else { return true }
            return items[items.index(before: index)] != item
        }
        else {
            return items.first != item
        }
    }

    func canMove(_ item: CastPlayerItem, after afterItem: CastPlayerItem?) -> Bool {
        guard items.contains(item) else { return false }
        if let afterItem {
            guard item != afterItem, let index = items.firstIndex(of: afterItem) else { return false }
            guard index < items.count - 1 else { return true }
            return items[items.index(after: index)] != item
        }
        else {
            return items.last != item
        }
    }
}
