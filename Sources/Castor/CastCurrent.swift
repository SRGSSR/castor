//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import GoogleCast

final class CastCurrent: NSObject {
    private let remoteMediaClient: GCKRemoteMediaClient
    var item: CastPlayerItem?

    init(remoteMediaClient: GCKRemoteMediaClient) {
        self.remoteMediaClient = remoteMediaClient
        if let mediaStatus = remoteMediaClient.mediaStatus {
            item = .init(id: mediaStatus.currentItemID, rawItem: mediaStatus.currentQueueItem)
        }
        super.init()
        remoteMediaClient.add(self)
    }
}

extension CastCurrent: GCKRemoteMediaClientListener {
    func remoteMediaClient(_ client: GCKRemoteMediaClient, didUpdate mediaStatus: GCKMediaStatus?) {
        if let mediaStatus {
            print("--> \(mediaStatus.currentItemID)")
            item = .init(id: mediaStatus.currentItemID, rawItem: mediaStatus.currentQueueItem)
        }
        else {
            item = nil
        }
    }
}
