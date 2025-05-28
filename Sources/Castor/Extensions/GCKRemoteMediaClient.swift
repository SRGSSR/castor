//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import GoogleCast

extension GCKRemoteMediaClient: ReceiverService {
    var requester: GCKRemoteMediaClient? {
        guard let mediaStatus else { return nil }
        return mediaStatus.isConnected ? self : nil
    }

    func status(from requester: GCKRemoteMediaClient) -> GCKMediaStatus? {
        requester.mediaStatus
    }
}
