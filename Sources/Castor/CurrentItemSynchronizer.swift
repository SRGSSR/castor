//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import GoogleCast

final class CurrentItemSynchronizer: NSObject {
    private let remoteMediaClient: GCKRemoteMediaClient

    private weak var request: GCKRequest?
    private var requestItemId: GCKMediaQueueItemID?
    private var pendingRequestItemId: GCKMediaQueueItemID?

    var currentItemId: GCKMediaQueueItemID? {
        didSet {
            guard currentItemId != oldValue else { return }
            if let currentItemId {
                if request == nil {
                    request = makeRequest(to: currentItemId)
                }
            }
            else {
                remoteMediaClient.stop()
            }
            pendingRequestItemId = currentItemId
        }
    }

    init(remoteMediaClient: GCKRemoteMediaClient) {
        self.remoteMediaClient = remoteMediaClient
        super.init()
        remoteMediaClient.add(self)
    }

    private func makeRequest(to itemID: GCKMediaQueueItemID) -> GCKRequest {
        let request = remoteMediaClient.queueJumpToItem(withID: itemID)
        request.delegate = self
        requestItemId = itemID
        return request
    }
}

extension CurrentItemSynchronizer: GCKRemoteMediaClientListener {
    func remoteMediaClient(_ client: GCKRemoteMediaClient, didUpdate mediaStatus: GCKMediaStatus?) {
        if let mediaStatus {
            if let pendingRequestItemId {
                let isPendingItemReached = mediaStatus.currentItemID == pendingRequestItemId
                let isPendingItemMissing = client.mediaQueue.indexOfItem(withID: pendingRequestItemId) == NSNotFound
                if isPendingItemReached || isPendingItemMissing {
                    currentItemId = mediaStatus.currentItemID
                    self.pendingRequestItemId = nil
                }
            }
            else {
                currentItemId = mediaStatus.currentItemID
            }
        }
        else {
            currentItemId = nil
        }
    }
}

extension CurrentItemSynchronizer: GCKRequestDelegate {
    func requestDidComplete(_ request: GCKRequest) {
        /// Performing a jump while another one is already performed might lead to the session stopping.
        guard let pendingRequestItemId, pendingRequestItemId != requestItemId else { return }
        self.request = makeRequest(to: pendingRequestItemId)
    }
}
