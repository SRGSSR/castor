//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import GoogleCast

final class ActiveTracksRecipe: NSObject, MutableSynchronizerRecipe {
    static let defaultValue: [CastMediaTrack] = []

    let service: GCKRemoteMediaClient

    private let update: (GCKMediaStatus?) -> Void
    private let completion: () -> Void

    var requester: GCKRemoteMediaClient? {
        service
    }

    init(service: GCKRemoteMediaClient, update: @escaping (GCKMediaStatus?) -> Void, completion: @escaping () -> Void) {
        self.service = service
        self.update = update
        self.completion = completion
        super.init()
        service.add(self)
    }

    static func status(from requester: GCKRemoteMediaClient) -> GCKMediaStatus? {
        requester.mediaStatus
    }

    static func value(from status: GCKMediaStatus) -> [CastMediaTrack] {
        Self.activeTracks(from: status)
    }

    func canMakeRequest(using requester: GCKRemoteMediaClient) -> Bool {
        requester.canMakeRequest()
    }

    func makeRequest(for value: [CastMediaTrack], using requester: GCKRemoteMediaClient) {
        let request = requester.setActiveTrackIDs(value.map { NSNumber(value: $0.trackIdentifier) })
        request.delegate = self
    }

    private static func activeTracks(from mediaStatus: GCKMediaStatus?) -> [CastMediaTrack] {
        guard let mediaStatus, let rawTracks = mediaStatus.mediaInformation?.mediaTracks, let activeTrackIDs = mediaStatus.activeTrackIDs else {
            return []
        }
        // swiftlint:disable:next legacy_objc_type
        return rawTracks.filter { activeTrackIDs.contains(NSNumber(value: $0.identifier)) }.map { .init(rawTrack: $0) }
    }
}

extension ActiveTracksRecipe: GCKRemoteMediaClientListener {
    func remoteMediaClient(_ client: GCKRemoteMediaClient, didUpdate mediaStatus: GCKMediaStatus?) {
        update(mediaStatus)
    }
}

extension ActiveTracksRecipe: GCKRequestDelegate {
    func requestDidComplete(_ request: GCKRequest) {
        completion()
    }
}
