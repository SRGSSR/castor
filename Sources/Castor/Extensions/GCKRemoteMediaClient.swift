//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import GoogleCast

extension GCKRemoteMediaClient: ReceiverService {
    var requester: GCKRemoteMediaClient? {
        self
    }

    func status(from requester: GCKRemoteMediaClient) -> GCKMediaStatus? {
        requester.mediaStatus
    }
}

extension GCKRemoteMediaClient {
    func canMakeRequest() -> Bool {
        mediaStatus?.isConnected == true
    }
}
