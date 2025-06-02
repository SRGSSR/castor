//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import GoogleCast

final class CurrentItemRecipe: NSObject, SynchronizerRecipe {
    static let defaultValue = kGCKMediaQueueInvalidItemID

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

    func value(from status: GCKMediaStatus) -> GCKMediaQueueItemID {
        if status.loadingItemID != kGCKMediaQueueInvalidItemID {
            return status.loadingItemID
        }
        else {
            return status.currentItemID
        }
    }

    func canMakeRequest(using requester: GCKRemoteMediaClient) -> Bool {
        requester.canMakeRequest()
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
