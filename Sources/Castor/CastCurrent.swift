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
            delegate?.didUpdate(item: Self.item(from: remoteMediaClient.mediaStatus))
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
            print("--> [request] \(request.requestID) did start, inProgress = \(request.inProgress)")
            self.request = request
            requestItemID = item.id
        }
        itemID = item.id
    }
}

private extension CastCurrent {
    private static func item(from mediaStatus: GCKMediaStatus?) -> CastPlayerItem? {
        guard let mediaStatus else { return nil }
        return .init(id: mediaStatus.currentItemID, rawItem: mediaStatus.currentQueueItem)
    }
}

extension CastCurrent: GCKRemoteMediaClientListener {
    func remoteMediaClient(_ client: GCKRemoteMediaClient, didUpdate mediaStatus: GCKMediaStatus?) {
        print("--> [status] did update, current \(mediaStatus?.currentItemID)")
        guard let mediaStatus else { return }
        if itemID == nil {
            itemID = mediaStatus.currentItemID
        }
        if mediaStatus.currentItemID == itemID {
            delegate?.didUpdate(item: Self.item(from: remoteMediaClient.mediaStatus))
        }
    }
}

extension CastCurrent: GCKRequestDelegate {
    func requestDidComplete(_ request: GCKRequest) {
        print("--> [request] \(request.requestID) did complete, inProgress = \(request.inProgress)")
        if let itemID, itemID != requestItemID {
            let request = remoteMediaClient.queueJumpToItem(withID: itemID)
            request.delegate = self
            print("--> [request] \(request.requestID) did start, inProgress = \(request.inProgress)")
            self.request = request
            requestItemID = itemID
        }
    }
}
