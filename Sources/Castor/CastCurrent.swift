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

    private var itemId: GCKMediaQueueItemID?
    private var requestItemId: GCKMediaQueueItemID?

    weak var delegate: CastCurrentDelegate?

    init(remoteMediaClient: GCKRemoteMediaClient) {
        self.remoteMediaClient = remoteMediaClient
        self.itemId = remoteMediaClient.mediaStatus?.currentItemID
        super.init()
        remoteMediaClient.add(self)
    }

    func jump(to item: CastPlayerItem) {
        if request == nil {
            request = jumpRequest(to: item.id)
        }
        itemId = item.id
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
        guard let mediaStatus else { return }
        if itemId == nil {
            itemId = mediaStatus.currentItemID
        }
        if mediaStatus.currentItemID == itemId {
            delegate?.didUpdate(item: .init(id: mediaStatus.currentItemID, rawItem: mediaStatus.currentQueueItem))
        }
    }
}

extension CastCurrent: GCKRequestDelegate {
    func requestDidComplete(_ request: GCKRequest) {
        if let itemId, itemId != requestItemId {
            self.request = jumpRequest(to: itemId)
        }
    }
}
