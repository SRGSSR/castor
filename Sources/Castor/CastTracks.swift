//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import GoogleCast

final class CastTracks: NSObject {
    private let remoteMediaClient: GCKRemoteMediaClient

    // swiftlint:disable:next discouraged_optional_collection
    @Published private(set) var targetTracks: [CastMediaTrack]?

    init(remoteMediaClient: GCKRemoteMediaClient) {
        self.remoteMediaClient = remoteMediaClient
    }

    func request(for tracks: [CastMediaTrack]) {
        targetTracks = tracks
        // swiftlint:disable:next legacy_objc_type
        let request = remoteMediaClient.setActiveTrackIDs(tracks.map { NSNumber(value: $0.trackIdentifier) })
        request.delegate = self
    }
}

extension CastTracks: GCKRequestDelegate {
    func requestDidComplete(_ request: GCKRequest) {
        targetTracks = nil
    }
}
