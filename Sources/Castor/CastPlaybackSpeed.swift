//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import GoogleCast

final class CastPlaybackSpeed: NSObject {
    private let remoteMediaClient: GCKRemoteMediaClient

    @Published private(set) var targetValue: Float?

    init(remoteMediaClient: GCKRemoteMediaClient) {
        self.remoteMediaClient = remoteMediaClient
    }

    func request(for value: Float) {
        targetValue = value
        let request = remoteMediaClient.setPlaybackRate(value)
        request.delegate = self
    }
}

extension CastPlaybackSpeed: GCKRequestDelegate {
    func requestDidComplete(_ request: GCKRequest) {
        targetValue = nil
    }
}
