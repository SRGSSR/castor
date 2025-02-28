//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import GoogleCast

final class JumpRequest: NSObject {
    private let remoteMediaClient: GCKRemoteMediaClient
    private var rawRequest: GCKRequest?
    private var id: UInt?

    init(remoteMediaClient: GCKRemoteMediaClient) {
        self.remoteMediaClient = remoteMediaClient
    }

    func jump(to id: UInt) {
        print("--> [single request] jump to item with \(id)")
        self.id = id
        executePending()
    }

    func cancel() {
        rawRequest?.cancel()
    }

    private func executePending() {
        guard let id, rawRequest == nil else { return }
        rawRequest = remoteMediaClient.queueJumpToItem(withID: id)
        print("--> [single request] did start \(rawRequest?.requestID)")
        self.id = nil
        rawRequest?.delegate = self
    }

    deinit {
        rawRequest?.cancel()
    }
}

extension JumpRequest: GCKRequestDelegate {
    func requestDidComplete(_ request: GCKRequest) {
        print("--> [single request] did complete \(request.requestID)")
        rawRequest = nil
        executePending()
    }

    func request(_ request: GCKRequest, didAbortWith abortReason: GCKRequestAbortReason) {
        print("--> [single request] did abort \(request.requestID) with \(abortReason)")
        rawRequest = nil
        executePending()
    }

    func request(_ request: GCKRequest, didFailWithError error: GCKError) {
        print("--> [single request] did fail \(request.requestID) with \(error)")
        rawRequest = nil
        executePending()
    }
}
