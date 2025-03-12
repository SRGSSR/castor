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
    private var itemID: GCKMediaQueueItemID?
    private weak var request: GCKRequest?
    private var requestItemID: GCKMediaQueueItemID?

    weak var delegate: CastCurrentDelegate? {
        didSet {
            guard let mediaStatus = remoteMediaClient.mediaStatus else { return }
            updateItem(for: mediaStatus)
        }
    }

    init(remoteMediaClient: GCKRemoteMediaClient) {
        self.remoteMediaClient = remoteMediaClient
        self.itemID = remoteMediaClient.mediaStatus?.currentItemID
        super.init()
        remoteMediaClient.add(self)
    }

    func jump(to item: CastPlayerItem) {
        if request == nil {
            let request = remoteMediaClient.queueJumpToItem(withID: item.id)
            request.delegate = self
            self.request = request
            requestItemID = item.id
        }
        itemID = item.id
    }

    private func updateItem(for mediaStatus: GCKMediaStatus) {
        guard mediaStatus.currentItemID == itemID else { return }
        delegate?.didUpdate(item: .init(id: mediaStatus.currentItemID, rawItem: mediaStatus.currentQueueItem))
    }
}

extension CastCurrent: GCKRemoteMediaClientListener {
    func remoteMediaClient(_ client: GCKRemoteMediaClient, didUpdate mediaStatus: GCKMediaStatus?) {
        guard let mediaStatus else { return }
        if itemID == nil {
            itemID = mediaStatus.currentItemID
        }
        updateItem(for: mediaStatus)
    }
}

extension CastCurrent: GCKRequestDelegate {
    func requestDidComplete(_ request: GCKRequest) {
        if let itemID, itemID != requestItemID {
            let request = remoteMediaClient.queueJumpToItem(withID: itemID)
            request.delegate = self
            self.request = request
            requestItemID = itemID
        }
    }
}
