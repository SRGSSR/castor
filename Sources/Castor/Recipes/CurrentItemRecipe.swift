//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import GoogleCast

final class CurrentItemRecipe: NSObject, MutableSynchronizerRecipe {
    static let defaultValue = kGCKMediaQueueInvalidItemID

    let service: GCKRemoteMediaClient

    private let update: (GCKMediaStatus?) -> Void
    private let completion: () -> Void

    var requester: GCKRemoteMediaClient? {
        service.canMakeRequest() ? service : nil
    }

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

    static func value(from status: GCKMediaStatus) -> GCKMediaQueueItemID {
        if status.loadingItemID != kGCKMediaQueueInvalidItemID {
            return status.loadingItemID
        }
        else {
            return status.currentItemID
        }
    }

    func makeRequest(for value: GCKMediaQueueItemID, using requester: GCKRemoteMediaClient) {
        let request = requester.queueJumpToItem(withID: value)
        request.delegate = self
    }
}

extension CurrentItemRecipe: GCKRemoteMediaClientListener {
    func remoteMediaClient(_ client: GCKRemoteMediaClient, didUpdate mediaStatus: GCKMediaStatus?) {
        update(mediaStatus)
    }
}

extension CurrentItemRecipe: GCKRequestDelegate {
    func requestDidComplete(_ request: GCKRequest) {
        completion()
    }
}
