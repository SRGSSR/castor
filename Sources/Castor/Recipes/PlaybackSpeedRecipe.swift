//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import GoogleCast

final class PlaybackSpeedRecipe: NSObject, MutableSynchronizerRecipe {
    static let defaultValue: Float = 1

    let service: GCKRemoteMediaClient

    private let update: (GCKMediaStatus?) -> Void
    private let completion: () -> Void

    init(service: GCKRemoteMediaClient, update: @escaping (GCKMediaStatus?) -> Void, completion: @escaping () -> Void) {
        self.service = service
        self.update = update
        self.completion = completion
        super.init()
        service.add(self)
    }

    static func status(from service: GCKRemoteMediaClient) -> GCKMediaStatus? {
        service.mediaStatus
    }

    static func value(from status: GCKMediaStatus) -> Float {
        status.playbackRate
    }

    func requester(for service: GCKRemoteMediaClient) -> GCKRemoteMediaClient? {
        service.canMakeRequest() ? service : nil
    }

    func makeRequest(for value: Float, using requester: GCKRemoteMediaClient) {
        let request = requester.setPlaybackRate(value)
        request.delegate = self
    }
}

extension PlaybackSpeedRecipe: GCKRemoteMediaClientListener {
    func remoteMediaClient(_ client: GCKRemoteMediaClient, didUpdate mediaStatus: GCKMediaStatus?) {
        update(mediaStatus)
    }
}

extension PlaybackSpeedRecipe: GCKRequestDelegate {
    func requestDidComplete(_ request: GCKRequest) {
        completion()
    }
}
