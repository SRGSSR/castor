//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import GoogleCast

final class RepeatModeRecipe: NSObject, SynchronizerRecipe {
    static let defaultValue: CastRepeatMode = .off

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

    func status(from requester: GCKRemoteMediaClient) -> GCKMediaStatus? {
        requester.mediaStatus
    }

    func value(from status: GCKMediaStatus) -> CastRepeatMode {
        CastRepeatMode(rawMode: status.queueRepeatMode) ?? .off
    }

    func canMakeRequest(using requester: GCKRemoteMediaClient) -> Bool {
        requester.canMakeRequest()
    }

    func makeRequest(for value: CastRepeatMode, using requester: GCKRemoteMediaClient) {
        let request = requester.queueSetRepeatMode(value.rawMode())
        request.delegate = self
    }
}

extension RepeatModeRecipe: GCKRemoteMediaClientListener {
    func remoteMediaClient(_ client: GCKRemoteMediaClient, didUpdate mediaStatus: GCKMediaStatus?) {
        update(mediaStatus)
    }
}

extension RepeatModeRecipe: GCKRequestDelegate {
    func requestDidComplete(_ request: GCKRequest) {
        completion()
    }
}
