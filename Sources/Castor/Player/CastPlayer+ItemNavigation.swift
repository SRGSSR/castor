//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

public extension CastPlayer {
    /// Checks whether returning to the previous item in the queue is possible.
    ///
    /// - Returns: `true` if possible.
    ///
    /// The behavior of this method is adjusted to wrap around both ends of the item queue when ``CastPlayer/repeatMode``
    /// has been set to ``CastRepeatMode/all``.
    ///
    /// > Important: Ignores the ``CastConfiguration/navigationMode`` set in the ``Cast/configuration``.
    func canReturnToPreviousItem() -> Bool {
        index(before: currentItem, in: items) != nil
    }

    /// Returns to the previous item in the queue.
    ///
    /// The behavior of this method is adjusted to wrap around both ends of the item queue when ``CastPlayer/repeatMode``
    /// has been set to ``CastRepeatMode/all``.
    ///
    /// > Important: Ignores the ``CastConfiguration/navigationMode`` set in the ``Cast/configuration``.
    func returnToPreviousItem() {
        guard let previousIndex = index(before: currentItem, in: items) else { return }
        currentItem = items[previousIndex]
    }

    /// Checks whether moving to the next item in the queue is possible.
    ///
    /// - Returns: `true` if possible.
    ///
    /// The behavior of this method is adjusted to wrap around both ends of the item queue when ``CastPlayer/repeatMode``
    /// has been set to ``CastRepeatMode/all``.
    ///
    /// > Important: Ignores the ``CastConfiguration/navigationMode`` set in the ``Cast/configuration``.
    func canAdvanceToNextItem() -> Bool {
        index(after: currentItem, in: items) != nil
    }

    /// Moves to the next item in the queue.
    ///
    /// The behavior of this method is adjusted to wrap around both ends of the item queue when ``CastPlayer/repeatMode``
    /// has been set to ``CastRepeatMode/all``.
    ///
    /// > Important: Ignores the ``CastConfiguration/navigationMode`` set in the ``Cast/configuration``.
    func advanceToNextItem() {
        guard let nextIndex = index(after: currentItem, in: items) else { return }
        currentItem = items[nextIndex]
    }
}

extension CastPlayer {
    func index(before item: CastPlayerItem?, in items: [CastPlayerItem]) -> Int? {
        guard let item, let index = items.firstIndex(of: item) else {
            return nil
        }
        let previousIndex = items.index(before: index)
        return previousIndex >= items.startIndex ? previousIndex : beforeIndex()
    }

    func index(after item: CastPlayerItem?, in items: [CastPlayerItem]) -> Int? {
        guard let item, let index = items.firstIndex(of: item) else { return nil }
        let nextIndex = items.index(after: index)
        return nextIndex < items.endIndex ? nextIndex : afterIndex()
    }
}

private extension CastPlayer {
    func beforeIndex() -> Int? {
        switch repeatMode {
        case .off, .one:
            return nil
        case .all:
            return items.index(before: items.endIndex)
        }
    }

    func afterIndex() -> Int? {
        switch repeatMode {
        case .off, .one:
            return nil
        case .all:
            return items.startIndex
        }
    }
}
