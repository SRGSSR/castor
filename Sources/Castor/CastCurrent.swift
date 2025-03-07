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
        self.item = Self.item(from: remoteMediaClient.mediaStatus)
        super.init()
        remoteMediaClient.add(self)
    }

    private static func item(from mediaStatus: GCKMediaStatus?) -> CastPlayerItem? {
        guard let mediaStatus else { return nil }
        return .init(id: mediaStatus.currentItemID, rawItem: mediaStatus.currentQueueItem)
    }
}

extension CastCurrent: GCKRemoteMediaClientListener {
    func remoteMediaClient(_ client: GCKRemoteMediaClient, didUpdate mediaStatus: GCKMediaStatus?) {
        item = Self.item(from: remoteMediaClient.mediaStatus)
    }
}
