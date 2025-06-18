//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import CoreMedia
import GoogleCast

public extension CastPlayer {
    /// Checks whether returning to the previous content is possible.
    ///
    /// - Returns: `true` if possible.
    ///
    /// The behavior of this method is adjusted to wrap around both ends of the item queue when ``CastPlayer/repeatMode``
    /// has been set to ``CastRepeatMode/all``.
    ///
    /// > Important: Observes the ``CastConfiguration/navigationMode`` set in the ``Cast/configuration``.
    func canReturnToPrevious() -> Bool {
        canReturn(before: currentItem, in: items, streamType: streamType)
    }

    /// Returns to the previous content.
    ///
    /// The behavior of this method is adjusted to wrap around both ends of the item queue when ``CastPlayer/repeatMode``
    /// has been set to ``CastRepeatMode/all``.
    ///
    /// > Important: Observes the ``CastConfiguration/navigationMode`` set in the ``Cast/configuration``.
    func returnToPrevious() {
        if shouldSeekToStartTime() {
            seek(to: .zero)
        }
        else {
            returnToPreviousItem()
        }
    }

    /// Checks whether moving to the next content is possible.
    ///
    /// - Returns: `true` if possible.
    ///
    /// The behavior of this method is adjusted to wrap around both ends of the item queue when ``CastPlayer/repeatMode``
    /// has been set to ``CastRepeatMode/all``.
    ///
    /// > Important: Observes the ``CastConfiguration/navigationMode`` set in the ``Cast/configuration``.
    func canAdvanceToNext() -> Bool {
        canAdvanceToNextItem()
    }

    /// Moves to the next content.
    ///
    /// The behavior of this method is adjusted to wrap around both ends of the item queue when ``CastPlayer/repeatMode``
    /// has been set to ``CastRepeatMode/all``.
    ///
    /// > Important: Observes the ``CastConfiguration/navigationMode`` set in the ``Cast/configuration``.
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
