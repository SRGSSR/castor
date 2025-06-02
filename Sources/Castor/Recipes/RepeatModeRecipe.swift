//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import GoogleCast

final class RepeatModeRecipe: NSObject, SynchronizerRecipe, GCKRemoteMediaClientListener {
    static let defaultValue: CastRepeatMode = .off

    let service: GCKRemoteMediaClient
    private let update: (GCKMediaStatus?) -> Void

    init(service: GCKRemoteMediaClient, update: @escaping (GCKMediaStatus?) -> Void) {
        self.service = service
        self.update = update
        super.init()
        service.add(self)
    }

    func value(from status: GCKMediaStatus) -> CastRepeatMode {
        CastRepeatMode(rawMode: status.queueRepeatMode) ?? .off
    }

    func canMakeRequest(using requester: GCKRemoteMediaClient) -> Bool {
        requester.canMakeRequest()
    }

    func makeRequest(for value: CastRepeatMode, using requester: GCKRemoteMediaClient) -> GCKRequest? {
        requester.queueSetRepeatMode(value.rawMode())
    }

    func remoteMediaClient(_ client: GCKRemoteMediaClient, didUpdate mediaStatus: GCKMediaStatus?) {
        update(mediaStatus)
    }
}
