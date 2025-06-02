//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import GoogleCast

final class CurrentSessionRecipe: NSObject, SynchronizerRecipe {
    static let defaultValue: GCKCastSession? = nil

    let service: GCKSessionManager

    private let update: (GCKCastSession?) -> Void
    private let completion: () -> Void

    init(service: GCKSessionManager, update: @escaping (GCKCastSession?) -> Void, completion: @escaping () -> Void) {
        self.service = service
        self.update = update
        self.completion = completion
        super.init()
        service.add(self)
    }

    static func status(from requester: GCKSessionManager) -> GCKCastSession? {
        requester.currentCastSession
    }

    static func value(from session: GCKCastSession) -> GCKCastSession {
        session
    }

    func canMakeRequest(using requester: GCKCastSession) -> Bool {
        true
    }

    func makeRequest(for value: Bool, using requester: GCKCastSession) {
        
    }

    func sessionManager(
        _ sessionManager: GCKSessionManager,
        castSession session: GCKCastSession,
        didReceiveDeviceVolume volume: Float,
        muted: Bool
    ) {

    }

    func sessionManager(_ sessionManager: GCKSessionManager, willEnd session: GCKCastSession) {

    }
}

extension CurrentSessionRecipe: GCKSessionManagerListener {
    func sessionManager(_ sessionManager: GCKSessionManager, willStart session: GCKCastSession) {

    }

    func sessionManager(_ sessionManager: GCKSessionManager, didStart session: GCKCastSession) {

    }

    func sessionManager(_ sessionManager: GCKSessionManager, didResumeCastSession session: GCKCastSession) {

    }

    func sessionManager(
        _ sessionManager: GCKSessionManager,
        didSuspend session: GCKCastSession,
        with reason: GCKConnectionSuspendReason
    ) {

    }

    func sessionManager(_ sessionManager: GCKSessionManager, didEnd session: GCKCastSession, withError error: (any Error)?) {

    }

    func sessionManager(
        _ sessionManager: GCKSessionManager,
        didFailToStart session: GCKCastSession,
        withError error: any Error
    ) {

    }
}
