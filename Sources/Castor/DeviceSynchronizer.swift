//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import GoogleCast

final class DeviceSynchronizer<Value>: NSObject, GCKSessionManagerListener, GCKRequestDelegate {
    private let session: GCKCastSession
    private let builder: (GCKCastSession, Value) -> GCKRequest
    private let parser: (Float, Bool) -> Value

    var update: ((Value) -> Void)?

    private weak var currentRequest: GCKRequest?
    private var pendingPlaybackSpeed: Value?

    init(
        sessionManager: GCKSessionManager,
        session: GCKCastSession,
        builder: @escaping (GCKCastSession, Value) -> GCKRequest,
        parser: @escaping (Float, Bool) -> Value
    ) {
        self.session = session
        self.builder = builder
        self.parser = parser
        super.init()
        sessionManager.add(self)
    }

    func requestUpdate(to value: Value) {
        if currentRequest == nil {
            currentRequest = makeRequest(to: value)
        }
        else {
            pendingPlaybackSpeed = value
        }
    }

    private func makeRequest(to value: Value) -> GCKRequest {
        update?(value)
        let request = builder(session, value)
        request.delegate = self
        return request
    }

    func sessionManager(
        _ sessionManager: GCKSessionManager,
        castSession session: GCKCastSession,
        didReceiveDeviceVolume volume: Float,
        muted: Bool
    ) { 
        if currentRequest == nil {
            let value = parser(volume, muted)
            update?(value)
        }
    }

    func requestDidComplete(_ request: GCKRequest) {
        if let pendingPlaybackSpeed {
            currentRequest = makeRequest(to: pendingPlaybackSpeed)
            self.pendingPlaybackSpeed = nil
        }
    }
}
