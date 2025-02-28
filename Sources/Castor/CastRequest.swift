//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import GoogleCast

final class CastRequest: NSObject {
    let rawRequest: GCKRequest

    init(rawRequest: GCKRequest) {
        print("--> did start \(rawRequest.requestID)")
        self.rawRequest = rawRequest
        super.init()
        rawRequest.delegate = self
    }

    func cancel() {
        rawRequest.cancel()
    }

    deinit {
        rawRequest.cancel()
    }
}

extension CastRequest: GCKRequestDelegate {
    func requestDidComplete(_ request: GCKRequest) {
        print("--> did complete \(request.requestID)")
    }

    func request(_ request: GCKRequest, didAbortWith abortReason: GCKRequestAbortReason) {
        print("--> did abort \(request.requestID) with \(abortReason)")
    }

    func request(_ request: GCKRequest, didFailWithError error: GCKError) {
        print("--> did fail \(request.requestID) with \(error)")
    }
}
