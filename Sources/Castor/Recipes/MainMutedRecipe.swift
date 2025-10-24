//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import GoogleCast

final class MainMutedRecipe: NSObject, MutableReceiverStateRecipe {
    static let defaultValue = false

    private let service: GCKSessionManager

    var update: ((Bool) -> Void)?
    var completion: ((Bool) -> Void)?

    private var currentSession: GCKCastSession? {
        didSet {
            update?(Self.muted(for: currentSession))
        }
    }

    init(service: GCKSessionManager) {
        self.service = service
        self.currentSession = service.currentCastSession
        super.init()
        service.add(self)
    }

    static func status(from service: GCKSessionManager) -> Bool {
        muted(for: service.currentCastSession)
    }

    private static func muted(for session: GCKCastSession?) -> Bool {
        session?.currentDeviceMuted ?? defaultValue
    }

    func requestUpdate(to value: Bool) -> Bool {
        guard let currentSession else { return false }
        let request = currentSession.setDeviceMuted(value)
        request.delegate = self
        return true
    }
}

extension MainMutedRecipe: @preconcurrency GCKSessionManagerListener {
    func sessionManager(_ sessionManager: GCKSessionManager, didStart session: GCKCastSession) {
        currentSession = session
    }

    func sessionManager(_ sessionManager: GCKSessionManager, didResumeCastSession session: GCKCastSession) {
        currentSession = session
    }

    func sessionManager(_ sessionManager: GCKSessionManager, didSuspend session: GCKCastSession, with reason: GCKConnectionSuspendReason) {
        currentSession = nil
    }

    func sessionManager(
        _ sessionManager: GCKSessionManager,
        castSession session: GCKCastSession,
        didReceiveDeviceVolume volume: Float,
        muted: Bool
    ) {
        update?(muted)
    }

    func sessionManager(_ sessionManager: GCKSessionManager, willEnd session: GCKCastSession) {
        currentSession = nil
    }

    func sessionManager(_ sessionManager: GCKSessionManager, didEnd session: GCKCastSession, withError error: (any Error)?) {
        currentSession = sessionManager.currentCastSession
    }

    func sessionManager(_ sessionManager: GCKSessionManager, didFailToStart session: GCKSession, withError error: any Error) {
        currentSession = sessionManager.currentCastSession
    }
}

extension MainMutedRecipe: @preconcurrency GCKRequestDelegate {
    func requestDidComplete(_ request: GCKRequest) {
        completion?(true)
    }

    func request(_ request: GCKRequest, didAbortWith abortReason: GCKRequestAbortReason) {
        completion?(false)
    }

    func request(_ request: GCKRequest, didFailWithError error: GCKError) {
        completion?(false)
    }
}
