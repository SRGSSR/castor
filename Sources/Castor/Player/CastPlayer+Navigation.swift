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
    func canReturnToPrevious() -> Bool {
        canReturn(before: currentItem, in: items, streamType: streamType)
    }

    /// Returns to the previous content in the queue.
    ///
    /// When ``CastPlayer/repeatMode`` is set to ``CastRepeatMode/all``, this method wraps around both ends of the queue.
    ///
    /// > Important: This action respects the ``CastConfiguration/navigationMode`` specified in ``Cast/configuration``.
    func returnToPrevious() {
        if shouldSeekToStartTime() {
            seek(to: .zero)
        }
        else {
            returnToPreviousItem()
        }
    }

    /// Checks whether it is possible to move to the next content in the queue.
    ///
    /// - Returns: `true` if moving to the next content is possible.
    ///
    /// When ``CastPlayer/repeatMode`` is set to ``CastRepeatMode/all``, this method wraps around both ends of the queue.
    ///
    /// > Important: This check respects the ``CastConfiguration/navigationMode`` specified in ``Cast/configuration``.
    func canAdvanceToNext() -> Bool {
        canAdvanceToNextItem()
    }

    /// Moves to the next content in the queue.
    ///
    /// When ``CastPlayer/repeatMode`` is set to ``CastRepeatMode/all``, this method wraps around both ends of the queue.
    ///
    /// > Important: This action respects the ``CastConfiguration/navigationMode`` specified in ``Cast/configuration``.
    func advanceToNext() {
        advanceToNextItem()
    }
}

extension CastPlayer {
    func canReturn(before item: CastPlayerItem?, in items: [CastPlayerItem], streamType: GCKMediaStreamType) -> Bool {
        switch configuration.navigationMode {
        case .smart where streamType == .buffered:
            return true
        default:
            return canReturnToItem(before: item, in: items)
        }
    }

    func canAdvance(after item: CastPlayerItem?, in items: [CastPlayerItem]) -> Bool {
        canAdvanceToItem(after: item, in: items)
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
