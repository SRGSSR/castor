//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import GoogleCast

final class MediaStatusRecipe: NSObject, ReceiverStateRecipe {
    static let defaultValue: GCKMediaStatus? = nil

    private let update: (GCKMediaStatus?) -> Void

    init(service: GCKRemoteMediaClient, update: @escaping (GCKMediaStatus?) -> Void) {
        self.update = update
        super.init()
        update(service.mediaStatus)
        service.add(self)
    }

    static func status(from service: GCKRemoteMediaClient) -> GCKMediaStatus? {
        service.mediaStatus
    }
}

extension MediaStatusRecipe: @preconcurrency GCKRemoteMediaClientListener {
    func remoteMediaClient(_ client: GCKRemoteMediaClient, didUpdate mediaStatus: GCKMediaStatus?) {
        update(mediaStatus)
    }
}
