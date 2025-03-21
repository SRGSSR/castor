//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import GoogleCast

protocol CastCurrentDelegate: AnyObject {
    func didUpdate(item: CastPlayerItem?)
}

final class CastCurrent: NSObject {
    private let remoteMediaClient: GCKRemoteMediaClient

    private weak var request: GCKRequest?
    private var requestItemId: GCKMediaQueueItemID?
    private var pendingRequestItemId: GCKMediaQueueItemID?

    weak var delegate: CastCurrentDelegate?

    init(remoteMediaClient: GCKRemoteMediaClient) {
        self.remoteMediaClient = remoteMediaClient
        super.init()
        remoteMediaClient.add(self)
    }

    func jump(to itemId: GCKMediaQueueItemID) {
        if request == nil {
            request = jumpRequest(to: itemId)
        }
        pendingRequestItemId = itemId
    }

    private func jumpRequest(to itemID: GCKMediaQueueItemID) -> GCKRequest {
        let request = remoteMediaClient.queueJumpToItem(withID: itemID)
        request.delegate = self
        requestItemId = itemID
        return request
    }
}

extension CastCurrent: GCKRemoteMediaClientListener {
    func remoteMediaClient(_ client: GCKRemoteMediaClient, didUpdate mediaStatus: GCKMediaStatus?) {
        if let mediaStatus {
            if let pendingRequestItemId {
                let isPendingItemReached = mediaStatus.currentItemID == pendingRequestItemId
                let isPendingItemMissing = client.mediaQueue.indexOfItem(withID: pendingRequestItemId) == NSNotFound
                if isPendingItemReached || isPendingItemMissing {
                    delegate?.didUpdate(item: .init(id: mediaStatus.currentItemID))
                    self.pendingRequestItemId = nil
                }
            }
            else {
                delegate?.didUpdate(item: .init(id: mediaStatus.currentItemID))
            }
        }
        else {
            delegate?.didUpdate(item: nil)
        }
    }
}

extension CastCurrent: GCKRequestDelegate {
    func requestDidComplete(_ request: GCKRequest) {
        guard let pendingRequestItemId, pendingRequestItemId != requestItemId else { return }
        self.request = jumpRequest(to: pendingRequestItemId)
    }
}
