//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import GoogleCast

protocol CastCurrentDelegate: AnyObject {
    func didUpdateItem(withId id: GCKMediaQueueItemID?)
}

/// This class is a workaround to avoid cast session instabilities when jumps are performed in quick succession.
/// It should ideally be removed if jumps are made reliable at the Google Cast SDK level directly.
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
        guard remoteMediaClient.mediaStatus?.currentItemID != itemId else { return }
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
                    delegate?.didUpdateItem(withId: mediaStatus.currentItemID)
                    self.pendingRequestItemId = nil
                }
            }
            else {
                delegate?.didUpdateItem(withId: mediaStatus.currentItemID)
            }
        }
        else {
            delegate?.didUpdateItem(withId: nil)
        }
    }
}

extension CastCurrent: GCKRequestDelegate {
    func requestDidComplete(_ request: GCKRequest) {
        guard let pendingRequestItemId, pendingRequestItemId != requestItemId else { return }
        self.request = jumpRequest(to: pendingRequestItemId)
    }
}
