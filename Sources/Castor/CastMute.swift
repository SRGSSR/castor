//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import GoogleCast

final class CastMute: NSObject {
    private let remoteMediaClient: GCKRemoteMediaClient

    @Published private(set) var targetMuted: Bool?

    init(remoteMediaClient: GCKRemoteMediaClient) {
        self.remoteMediaClient = remoteMediaClient
    }

    func request(for muted: Bool) {
        targetMuted = muted
        let request = remoteMediaClient.setStreamMuted(muted)
        request.delegate = self
    }
}

extension CastMute: GCKRequestDelegate {
    func requestDidComplete(_ request: GCKRequest) {
        targetMuted = nil
    }
}

