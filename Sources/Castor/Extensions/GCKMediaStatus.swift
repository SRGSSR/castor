//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import GoogleCast

extension GCKMediaStatus {
    var isConnected: Bool {
        queueItemCount != 0
    }

    func items() -> [GCKMediaQueueItem] {
        (0..<queueItemCount).compactMap { queueItem(at: $0) }
    }

    func activeTracks() -> [CastMediaTrack] {
        guard let rawTracks = mediaInformation?.mediaTracks, let activeTrackIDs else {
            return []
        }
        // swiftlint:disable:next legacy_objc_type
        return rawTracks.filter { activeTrackIDs.contains(NSNumber(value: $0.identifier)) }.map(CastMediaTrack.init)
    }
}
