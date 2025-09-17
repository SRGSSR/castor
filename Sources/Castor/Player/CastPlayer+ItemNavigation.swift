//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import CoreMedia
import GoogleCast

public extension CastPlayer {
    /// Checks whether it is possible to return to the previous content.
    ///
    /// - Returns: `true` if returning to the previous content is possible.
    ///
    /// When ``CastPlayer/repeatMode`` is set to ``CastRepeatMode/all``, this method wraps around both ends of the queue.
    ///
    /// > Important: This check respects the ``CastConfiguration/navigationMode`` specified in ``Cast/configuration``.
    func canReturnToPreviousItem() -> Bool {
        canReturnToItem(before: currentItem, in: items, streamType: streamType)
    }

    /// Returns to the previous content in the queue.
    ///
    /// When ``CastPlayer/repeatMode`` is set to ``CastRepeatMode/all``, this method wraps around both ends of the queue.
    ///
    /// > Important: This action respects the ``CastConfiguration/navigationMode`` specified in ``Cast/configuration``.
    func returnToPreviousItem() {
        if shouldSeekToStartTime() {
            seek(to: .zero)
        }
        else if let previousIndex = index(before: currentItem, in: items) {
            currentItem = items[previousIndex]
        }
    }

    /// Checks whether it is possible to move to the next content in the queue.
    ///
    /// - Returns: `true` if moving to the next content is possible.
    ///
    /// When ``CastPlayer/repeatMode`` is set to ``CastRepeatMode/all``, this method wraps around both ends of the queue.
    ///
    /// > Important: This check respects the ``CastConfiguration/navigationMode`` specified in ``Cast/configuration``.
    func canAdvanceToNextItem() -> Bool {
        canAdvanceToItem(after: currentItem, in: items)
    }

    /// Moves to the next content in the queue.
    ///
    /// When ``CastPlayer/repeatMode`` is set to ``CastRepeatMode/all``, this method wraps around both ends of the queue.
    ///
    /// > Important: This action respects the ``CastConfiguration/navigationMode`` specified in ``Cast/configuration``.
    func advanceToNextItem() {
        guard let nextIndex = index(after: currentItem, in: items) else { return }
        currentItem = items[nextIndex]
    }
}

private extension CastPlayer {
    func canReturnToItem(before item: CastPlayerItem?, in items: [CastPlayerItem], streamType: GCKMediaStreamType) -> Bool {
        switch configuration.navigationMode {
        case .smart where streamType == .buffered:
            return true
        default:
            return index(before: item, in: items) != nil
        }
    }

    func canAdvanceToItem(after item: CastPlayerItem?, in items: [CastPlayerItem]) -> Bool {
        index(after: item, in: items) != nil
    }
}

private extension CastPlayer {
    func isAwayFromStartTime(withInterval interval: TimeInterval) -> Bool {
        let time = time()
        let seekableTimeRange = seekableTimeRange()
        return time.isValid && seekableTimeRange.isValid && (time - seekableTimeRange.start).seconds >= interval
    }

    func shouldSeekToStartTime() -> Bool {
        switch configuration.navigationMode {
        case .immediate:
            return false
        case let .smart(interval: interval):
            return (streamType == .buffered && isAwayFromStartTime(withInterval: interval)) || !canReturnToPreviousItem()
        }
    }
}

private extension CastPlayer {
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
