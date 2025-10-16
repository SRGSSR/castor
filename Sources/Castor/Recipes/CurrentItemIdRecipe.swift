//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import GoogleCast

final class CurrentItemIdRecipe: NSObject, MutableReceiverStateRecipe {
    static let defaultValue = kGCKMediaQueueInvalidItemID

    private let service: GCKRemoteMediaClient

    private let update: (GCKMediaStatus?) -> Void
    private let completion: (Bool) -> Void

    init(service: GCKRemoteMediaClient, update: @escaping (GCKMediaStatus?) -> Void, completion: @escaping (Bool) -> Void) {
        self.service = service
        self.update = update
        self.completion = completion
        super.init()
        service.add(self)
    }

    static func status(from service: GCKRemoteMediaClient) -> GCKMediaStatus? {
        service.mediaStatus
    }

    static func value(from status: GCKMediaStatus?) -> GCKMediaQueueItemID {
        guard let status else { return kGCKMediaQueueInvalidItemID }
        return status.loadingItemID != kGCKMediaQueueInvalidItemID ? status.loadingItemID : status.currentItemID
    }

    func requestUpdate(to value: GCKMediaQueueItemID) -> Bool {
        guard service.canMakeRequest() else { return false }
        let request = service.queueJumpToItem(withID: value)
        request.delegate = self
        return true
    }
}

extension CurrentItemIdRecipe: @preconcurrency GCKRemoteMediaClientListener {
    func remoteMediaClient(_ client: GCKRemoteMediaClient, didUpdate mediaStatus: GCKMediaStatus?) {
        update(mediaStatus)
    }
}

extension CurrentItemIdRecipe: @preconcurrency GCKRequestDelegate {
    func requestDidComplete(_ request: GCKRequest) {
        completion(true)
    }

    func request(_ request: GCKRequest, didAbortWith abortReason: GCKRequestAbortReason) {
        completion(false)
    }

    func request(_ request: GCKRequest, didFailWithError error: GCKError) {
        completion(false)
    }
}
