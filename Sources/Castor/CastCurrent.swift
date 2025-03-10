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
    private var jumpRequest: GCKRequest?
    private var lastTargetItem: CastPlayerItem?

    private var isJumping: Bool {
        jumpRequest != nil
    }

    weak var delegate: CastCurrentDelegate? {
        didSet {
            if !isJumping {
                delegate?.didUpdate(item: Self.item(from: remoteMediaClient.mediaStatus))
            }
        }
    }

    init(remoteMediaClient: GCKRemoteMediaClient) {
        self.remoteMediaClient = remoteMediaClient
        super.init()
        remoteMediaClient.add(self)
    }

    func jump(to item: CastPlayerItem) {
        if jumpRequest == nil {
            jumpRequest = remoteMediaClient.queueJumpToItem(withID: item.id)
            jumpRequest?.delegate = self
        }
        else {
            lastTargetItem = item
        }
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
        if !isJumping {
            delegate?.didUpdate(item: Self.item(from: remoteMediaClient.mediaStatus))
        }
    }
}

extension CastCurrent: GCKRequestDelegate {
    func requestDidComplete(_ request: GCKRequest) {
        if let target = lastTargetItem {
            jumpRequest = remoteMediaClient.queueJumpToItem(withID: target.id)
            jumpRequest?.delegate = self
            lastTargetItem = nil
        }
        else {
            jumpRequest = nil
        }
    }
}
