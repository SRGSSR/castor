//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import GoogleCast

final class CurrentItemRecipe: NSObject, SynchronizerRecipe, GCKRemoteMediaClientListener {
    static let defaultValue = kGCKMediaQueueInvalidItemID

    let service: GCKRemoteMediaClient
    private let update: (GCKMediaStatus?) -> Void

    init(service: GCKRemoteMediaClient, update: @escaping (GCKMediaStatus?) -> Void) {
        self.service = service
        self.update = update
        super.init()
        service.add(self)
    }

    func value(from status: GCKMediaStatus) -> GCKMediaQueueItemID {
        if status.loadingItemID != kGCKMediaQueueInvalidItemID {
            return status.loadingItemID
        }
        else {
            return status.currentItemID
        }
    }

    func makeRequest(for value: GCKMediaQueueItemID, using requester: GCKRemoteMediaClient) -> GCKRequest? {
        requester.queueJumpToItem(withID: value)
    }

    func remoteMediaClient(_ client: GCKRemoteMediaClient, didUpdate mediaStatus: GCKMediaStatus?) {
        update(mediaStatus)
    }
}
