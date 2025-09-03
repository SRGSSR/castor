//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

public extension CastPlayer {
    /// Checks whether it is possible to return to the previous item in the queue.
    ///
    /// - Returns: `true` if returning to the previous item is possible.
    ///
    /// When ``CastPlayer/repeatMode`` is set to ``CastRepeatMode/all``, this method wraps around both ends of the queue.
    ///
    /// > Important: This check ignores the ``CastConfiguration/navigationMode`` specified in ``Cast/configuration``.
    func canReturnToPreviousItem() -> Bool {
        canReturnToItem(before: currentItem, in: items)
    }

    /// Returns to the previous item in the queue.
    ///
    /// When ``CastPlayer/repeatMode`` is set to ``CastRepeatMode/all``, this method wraps around both ends of the queue.
    ///
    /// > Important: This action ignores the ``CastConfiguration/navigationMode`` specified in ``Cast/configuration``.
    func returnToPreviousItem() {
        guard let previousIndex = index(before: currentItem, in: items) else { return }
        currentItem = items[previousIndex]
    }

    /// Checks whether it is possible to move to the next item in the queue.
    ///
    /// - Returns: `true` if moving to the next item is possible.
    ///
    /// When ``CastPlayer/repeatMode`` is set to ``CastRepeatMode/all``, this method wraps around both ends of the queue.
    ///
    /// > Important: This check ignores the ``CastConfiguration/navigationMode`` specified in ``Cast/configuration``.
    func canAdvanceToNextItem() -> Bool {
        canAdvanceToItem(after: currentItem, in: items)
    }

    /// Moves to the next item in the queue.
    ///
    /// When ``CastPlayer/repeatMode`` is set to ``CastRepeatMode/all``, this method wraps around both ends of the queue.
    ///
    /// > Important: This action ignores the ``CastConfiguration/navigationMode`` specified in ``Cast/configuration``.
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

extension CastPlayer {
    func canReturnToItem(before item: CastPlayerItem?, in items: [CastPlayerItem]) -> Bool {
        index(before: item, in: items) != nil
    }

    func canAdvanceToItem(after item: CastPlayerItem?, in items: [CastPlayerItem]) -> Bool {
        index(after: item, in: items) != nil
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
