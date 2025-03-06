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
        if let status = remoteMediaClient.mediaStatus {
            self.item = .init(id: status.currentItemID, rawItem: status.currentQueueItem)
        }
        super.init()
        remoteMediaClient.add(self)
    }
}

extension CastCurrent: GCKRemoteMediaClientListener {
}
