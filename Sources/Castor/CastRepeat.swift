//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import GoogleCast

final class CastRepeat: NSObject {
    private let remoteMediaClient: GCKRemoteMediaClient

    @Published private(set) var targetMode: CastRepeatMode?

    init(remoteMediaClient: GCKRemoteMediaClient) {
        self.remoteMediaClient = remoteMediaClient
    }

    func request(for mode: CastRepeatMode) {
        targetMode = mode
        let request = remoteMediaClient.queueSetRepeatMode(mode.rawMode())
        request.delegate = self
    }
}

extension CastRepeat: GCKRequestDelegate {
    func requestDidComplete(_ request: GCKRequest) {
        targetMode = nil
    }
}
