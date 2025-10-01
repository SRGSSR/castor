//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import CoreMedia
import GoogleCast

extension GCKRemoteMediaClient {
    private static func resumeItems(from mediaStatus: GCKMediaStatus) -> [CastResumeItem] {
        mediaStatus.items().compactMap { CastResumeItem(from: $0) }
    }

    func canMakeRequest() -> Bool {
        mediaStatus?.isConnected == true
    }

    func resumeState() -> CastResumeState? {
        guard let mediaStatus else { return nil }
        let resumeItems = Self.resumeItems(from: mediaStatus)
        let index = resumeItems.firstIndex { $0.item.itemID == mediaStatus.currentItemID }
        let options = CastLoadOptions(
            index: index ?? 0,
            time: time() - seekableTimeRange().start,
            shouldPlay: mediaStatus.shouldPlay,
            playbackSpeed: mediaStatus.playbackRate,
            repeatMode: .init(rawMode: mediaStatus.queueRepeatMode) ?? .off
        )
        guard var resumeState = CastResumeState(assets: resumeItems.map(\.asset), options: options) else {
            return nil
        }
        mediaStatus.activeTracks().forEach { track in
            guard let language = track.languageCode, let characteristic = track.mediaCharacteristic else { return }
            resumeState.setMediaSelection(language: language, for: characteristic)
        }
        return resumeState
    }
}

extension GCKRemoteMediaClient {
    private static func isValidTimeInterval(_ timeInterval: TimeInterval) -> Bool {
        GCKIsValidTimeInterval(timeInterval) && timeInterval != .infinity
    }

    func time() -> CMTime {
        .init(seconds: approximateStreamPosition(), preferredTimescale: CMTimeScale(NSEC_PER_SEC))
    }

    func seekableTimeRange() -> CMTimeRange {
        let start = approximateLiveSeekableRangeStart()
        let end = approximateLiveSeekableRangeEnd()
        if Self.isValidTimeInterval(start), Self.isValidTimeInterval(end), start != end {
            return .init(
                start: .init(seconds: start, preferredTimescale: CMTimeScale(NSEC_PER_SEC)),
                end: .init(seconds: end, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
            )
        }
        else if let streamDuration = mediaStatus?.mediaInformation?.streamDuration, Self.isValidTimeInterval(streamDuration), streamDuration != 0 {
            return .init(start: .zero, end: .init(seconds: streamDuration, preferredTimescale: CMTimeScale(NSEC_PER_SEC)))
        }
        else {
            return .invalid
        }
    }
}
