//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import GoogleCast

final class MediaStatusRecipe: NSObject, SynchronizerRecipe, GCKRemoteMediaClientListener {
    static let defaultValue: GCKMediaStatus? = nil

    let service: GCKRemoteMediaClient
    private let update: (GCKMediaStatus?) -> Void

    init(service: GCKRemoteMediaClient, update: @escaping (GCKMediaStatus?) -> Void) {
        self.service = service
        self.update = update
        super.init()
        service.add(self)
    }

    func value(from status: GCKMediaStatus) -> GCKMediaStatus? {
        status
    }

    func makeRequest(for value: GCKMediaStatus?, using requester: GCKRemoteMediaClient) -> GCKRequest? {
        nil
    }

    func remoteMediaClient(_ client: GCKRemoteMediaClient, didUpdate mediaStatus: GCKMediaStatus?) {
       update(mediaStatus)
    }
}
