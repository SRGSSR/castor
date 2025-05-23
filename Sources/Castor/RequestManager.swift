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

    func setShouldPlay(_ shouldPlay: Bool, completion: @escaping () -> Void) {
        if shouldPlay {
            execute(remoteMediaClient.play(), completion: completion)
        }
        else {
            execute(remoteMediaClient.pause(), completion: completion)
        }
    }

    func setRepeatMode(_ repeatMode: CastRepeatMode, completion: @escaping () -> Void) {
        execute(remoteMediaClient.queueSetRepeatMode(repeatMode.rawMode()), completion: completion)
    }

    private func execute(_ request: GCKRequest, completion: @escaping () -> Void) {
        request.delegate = self
        completions[request.requestID] = completion
    }

    // TOOD: Could implement a cancel all. Could be called from `CastPlayer.deinit`
}

extension RequestManager: GCKRequestDelegate {
    func requestDidComplete(_ request: GCKRequest) {
        print("--> did complete")
        completions[request.requestID]?()
        completions.removeValue(forKey: request.requestID)
    }

    func request(_ request: GCKRequest, didAbortWith abortReason: GCKRequestAbortReason) {
        print("--> did abort")
        completions.removeValue(forKey: request.requestID)
    }

    func request(_ request: GCKRequest, didFailWithError error: GCKError) {
        print("--> did fail")
        completions.removeValue(forKey: request.requestID)
    }
}
