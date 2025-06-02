//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import GoogleCast

final class PlaybackSpeedRecipe: NSObject, SynchronizerRecipe, GCKRemoteMediaClientListener {
    static let defaultValue: Float = 1

    let service: GCKRemoteMediaClient
    private let update: (GCKMediaStatus?) -> Void

    init(service: GCKRemoteMediaClient, update: @escaping (GCKMediaStatus?) -> Void) {
        self.service = service
        self.update = update
        super.init()
        service.add(self)
    }

    func value(from status: GCKMediaStatus) -> Float {
        status.playbackRate
    }

    func canMakeRequest(using requester: GCKRemoteMediaClient) -> Bool {
        requester.canMakeRequest()
    }

    func makeRequest(for value: Float, using requester: GCKRemoteMediaClient) -> GCKRequest? {
        requester.setPlaybackRate(value)
    }

    func remoteMediaClient(_ client: GCKRemoteMediaClient, didUpdate mediaStatus: GCKMediaStatus?) {
        update(mediaStatus)
    }
}
