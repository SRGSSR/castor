//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import GoogleCast
import SwiftUI

public extension CastPlayer {
    /// The items currently queued by the player.
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

    /// Loads player items from the specified assets and starts playback.
    ///
    /// - Parameters:
    ///   - assets: The assets to load as player items.
    ///   - options: The options to use when loading.
    func loadItems(from assets: [CastAsset], with options: CastLoadOptions = .init()) {
        let queueDataBuilder = GCKMediaQueueDataBuilder(queueType: .generic)
        queueDataBuilder.items = Self.rawItems(from: assets)
        queueDataBuilder.startIndex = UInt(options.startIndex)

        let loadRequestDataBuilder = GCKMediaLoadRequestDataBuilder()
        loadRequestDataBuilder.queueData = queueDataBuilder.build()
        if options.startTime.isValid {
            loadRequestDataBuilder.startTime = options.startTime.seconds
        }
        remoteMediaClient.loadMedia(with: loadRequestDataBuilder.build())
    }

    /// Loads a player item from the specified asset and starts playback.
    ///
    /// - Parameters:
    ///   - asset: The asset to load as a player item.
    ///   - options: The options to use when loading.
    func loadItem(from asset: CastAsset, with options: CastLoadOptions = .init()) {
        loadItems(from: [asset], with: options)
    }

    /// Inserts items before a specified item in the queue.
    ///
    /// - Parameters:
    ///   - assets: The assets to insert as player items.
    ///   - beforeItem: The item before which the new items should be inserted. Pass `nil` to insert at the front of the queue.
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

    /// Inserts items after a specified item in the queue.
    ///
    /// - Parameters:
    ///   - assets: The assets to insert as player items.
    ///   - afterItem: The item after which the new items should be inserted. Pass `nil` to insert at the end of the queue.
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

    /// Inserts an item after a specified item in the queue.
    ///
    /// - Parameters:
    ///   - asset: The asset to insert as a player item.
    ///   - afterItem: The item after which the new item should be inserted. Pass `nil` to insert at the end of the queue.
    @discardableResult
    func insertItem(from asset: CastAsset, after afterItem: CastPlayerItem?) -> Bool {
        insertItems(from: [asset], after: afterItem)
    }

    /// Inserts an item before a specified item in the queue.
    ///
    /// - Parameters:
    ///   - asset: The asset to insert as a player item.
    ///   - beforeItem: The item before which the new item should be inserted. Pass `nil` to insert at the front of the queue.
    @discardableResult
    func insertItem(from asset: CastAsset, before beforeItem: CastPlayerItem?) -> Bool {
        insertItems(from: [asset], before: beforeItem)
    }

    /// Appends items to the end of the queue.
    ///
    /// - Parameter assets: The assets to append as player items.
    func appendItems(from assets: [CastAsset]) {
        if !items.isEmpty {
            remoteMediaClient.queueInsert(Self.rawItems(from: assets), beforeItemWithID: kGCKMediaQueueInvalidItemID)
        }
        else {
            loadItems(from: assets)
        }
    }

    /// Appends an item to the end of the queue.
    ///
    /// - Parameter asset: The asset to append as a player item.
    func appendItem(from asset: CastAsset) {
        appendItems(from: [asset])
    }

    /// Prepends items to the front of the queue.
    ///
    /// - Parameter assets: The assets to prepend as player items.
    func prependItems(from assets: [CastAsset]) {
        if let firstItem = items.first {
            remoteMediaClient.queueInsert(Self.rawItems(from: assets), beforeItemWithID: firstItem.id)
        }
        else {
            loadItems(from: assets)
        }
    }

    /// Prepends an item to the front of the queue.
    ///
    /// - Parameter asset: The asset to prepend as a player item.
    func prependItem(from asset: CastAsset) {
        prependItems(from: [asset])
    }
}

public extension CastPlayer {
    /// Removes an item from the queue.
    ///
    /// - Parameter item: The player item to remove.
    func remove(_ item: CastPlayerItem) {
        items.removeAll { $0 == item }
    }

    /// Removes all items from the queue.
    func removeAllItems() {
        items.removeAll()
    }
}

public extension CastPlayer {
    /// Moves an item before another item in the queue.
    ///
    /// - Parameters:
    ///   - item: The item to move. Has no effect if the item does not belong to the queue.
    ///   - beforeItem: The item before which the moved item should be placed. Pass `nil` to move it to the front.
    /// - Returns: `true` if the item was successfully moved; otherwise, `false`.
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

    /// Moves an item after another item in the queue.
    ///
    /// - Parameters:
    ///   - item: The item to move. Has no effect if the item does not belong to the queue.
    ///   - afterItem: The item after which the moved item should be placed. Pass `nil` to move it to the back.
    /// - Returns: `true` if the item was successfully moved; otherwise, `false`.
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
