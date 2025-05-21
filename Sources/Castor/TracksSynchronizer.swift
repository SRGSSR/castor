//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import GoogleCast

final class ActiveTracksSynchronizer: NSObject {
    private let remoteMediaClient: GCKRemoteMediaClient

    var tracks: [CastMediaTrack] {
        didSet {
            guard Self.tracks(for: remoteMediaClient.mediaStatus) != tracks else { return }
            // swiftlint:disable:next legacy_objc_type
            remoteMediaClient.setActiveTrackIDs(tracks.map { NSNumber(value: $0.trackIdentifier) })
        }
    }

    init(remoteMediaClient: GCKRemoteMediaClient) {
        self.remoteMediaClient = remoteMediaClient
        self.tracks = Self.tracks(for: remoteMediaClient.mediaStatus)
        super.init()
        remoteMediaClient.add(self)
    }

    private static func tracks(for mediaStatus: GCKMediaStatus?) -> [CastMediaTrack] {
        guard let mediaStatus, let rawTracks = mediaStatus.mediaInformation?.mediaTracks, let activeTrackIDs = mediaStatus.activeTrackIDs else {
            return []
        }
        // swiftlint:disable:next legacy_objc_type
        return rawTracks.filter { activeTrackIDs.contains(NSNumber(value: $0.identifier)) }.map { .init(rawTrack: $0) }
    }
}

extension ActiveTracksSynchronizer: GCKRemoteMediaClientListener {
    func remoteMediaClient(_ client: GCKRemoteMediaClient, didUpdate mediaStatus: GCKMediaStatus?) {
        tracks = Self.tracks(for: mediaStatus)
    }
}
