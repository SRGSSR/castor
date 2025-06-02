//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import GoogleCast

final class ActiveTracksRecipe: NSObject, SynchronizerRecipe, GCKRemoteMediaClientListener {
    static let defaultValue: [CastMediaTrack] = []

    let service: GCKRemoteMediaClient
    private let update: (GCKMediaStatus?) -> Void

    init(service: GCKRemoteMediaClient, update: @escaping (GCKMediaStatus?) -> Void) {
        self.service = service
        self.update = update
        super.init()
        service.add(self)
    }

    func value(from status: GCKMediaStatus) -> [CastMediaTrack] {
        Self.activeTracks(from: status)
    }

    func canMakeRequest(using requester: GCKRemoteMediaClient) -> Bool {
        requester.canMakeRequest()
    }

    func makeRequest(for value: [CastMediaTrack], using requester: GCKRemoteMediaClient) -> GCKRequest? {
        requester.setActiveTrackIDs(value.map { NSNumber(value: $0.trackIdentifier) })
    }

    func remoteMediaClient(_ client: GCKRemoteMediaClient, didUpdate mediaStatus: GCKMediaStatus?) {
        update(mediaStatus)
    }

    private static func activeTracks(from mediaStatus: GCKMediaStatus?) -> [CastMediaTrack] {
        guard let mediaStatus, let rawTracks = mediaStatus.mediaInformation?.mediaTracks, let activeTrackIDs = mediaStatus.activeTrackIDs else {
            return []
        }
        // swiftlint:disable:next legacy_objc_type
        return rawTracks.filter { activeTrackIDs.contains(NSNumber(value: $0.identifier)) }.map { .init(rawTrack: $0) }
    }
}
