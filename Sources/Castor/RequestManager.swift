//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import GoogleCast

final class RequestManager: NSObject {
    private let remoteMediaClient: GCKRemoteMediaClient
    private var completions: [GCKRequestID: () -> Void] = [:]

    init(remoteMediaClient: GCKRemoteMediaClient) {
        self.remoteMediaClient = remoteMediaClient
    }

    func setRepeatMode(_ repeatMode: CastRepeatMode, completion: @escaping () -> Void) {
        execute(remoteMediaClient.queueSetRepeatMode(repeatMode.rawMode()), completion: completion)
    }

    private func execute(_ request: GCKRequest, completion: @escaping () -> Void) {
        completions[request.requestID] = completion
    }
}

extension RequestManager: GCKRequestDelegate {
    func requestDidComplete(_ request: GCKRequest) {
        completions[request.requestID]?()
        completions.removeValue(forKey: request.requestID)
    }

    func request(_ request: GCKRequest, didAbortWith abortReason: GCKRequestAbortReason) {
        completions.removeValue(forKey: request.requestID)
    }

    func request(_ request: GCKRequest, didFailWithError error: GCKError) {
        completions.removeValue(forKey: request.requestID)
    }
}
