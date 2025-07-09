//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import CoreMedia
import GoogleCast

extension GCKRemoteMediaClient {
    private static func resumeItems(from mediaStatus: GCKMediaStatus, with delegate: CastDelegate) -> [ResumeItem] {
        mediaStatus.items().compactMap { ResumeItem(from: $0, with: delegate) }
    }

    func canMakeRequest() -> Bool {
        mediaStatus?.isConnected == true
    }

    func resumeState(with delegate: CastDelegate) -> CastResumeState? {
        guard let mediaStatus else { return nil }
        let resumeItems = Self.resumeItems(from: mediaStatus, with: delegate)
        let index = resumeItems.firstIndex(where: { $0.item.itemID == mediaStatus.currentItemID })
        return CastResumeState(assets: resumeItems.map(\.asset), index: index, time: time() - seekableTimeRange().start)
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
