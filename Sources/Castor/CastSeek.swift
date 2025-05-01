//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import CoreMedia
import GoogleCast

final class CastSeek: NSObject {
    private let remoteMediaClient: GCKRemoteMediaClient

    @Published private(set) var targetTime: CMTime?

    init(remoteMediaClient: GCKRemoteMediaClient) {
        self.remoteMediaClient = remoteMediaClient
    }

    func request(for time: CMTime) {
        targetTime = time
        let options = GCKMediaSeekOptions()
        options.interval = time.seconds
        let request = remoteMediaClient.seek(with: options)
        request.delegate = self
    }
}

extension CastSeek: GCKRequestDelegate {
    func requestDidComplete(_ request: GCKRequest) {
        targetTime = nil
    }

    func request(_ request: GCKRequest, didAbortWith abortReason: GCKRequestAbortReason) {
        targetTime = nil
    }

    func request(_ request: GCKRequest, didFailWithError error: GCKError) {
        targetTime = nil
    }
}
