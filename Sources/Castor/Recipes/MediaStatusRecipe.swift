//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import GoogleCast

final class MediaStatusRecipe: NSObject, SynchronizerRecipe {
    static let defaultValue: GCKMediaStatus? = nil

    let service: GCKRemoteMediaClient

    private let update: (GCKMediaStatus?) -> Void

    var requester: GCKRemoteMediaClient? {
        service
    }

    init(service: GCKRemoteMediaClient, update: @escaping (GCKMediaStatus?) -> Void) {
        self.service = service
        self.update = update
        super.init()
        service.add(self)
    }

    static func status(from service: GCKRemoteMediaClient) -> GCKMediaStatus? {
        service.mediaStatus
    }

    static func value(from status: GCKMediaStatus) -> GCKMediaStatus? {
        status
    }
}

extension MediaStatusRecipe: GCKRemoteMediaClientListener {
    func remoteMediaClient(_ client: GCKRemoteMediaClient, didUpdate mediaStatus: GCKMediaStatus?) {
       update(mediaStatus)
    }
}
