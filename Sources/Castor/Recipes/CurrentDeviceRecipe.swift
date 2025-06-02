//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import GoogleCast

final class CurrentDeviceRecipe: NSObject, SynchronizerRecipe {
    static let defaultValue: GCKDevice? = nil

    let service: GCKSessionManager

    private let update: (GCKCastSession?) -> Void
    private let completion: () -> Void

    var requester: GCKSessionManager? {
        service
    }

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

    static func value(from session: GCKCastSession) -> GCKDevice? {
        session.device
    }

    func canMakeRequest(using requester: GCKSessionManager) -> Bool {
        true
    }

    func makeRequest(for value: GCKDevice?, using requester: GCKSessionManager) {
        if let value {
            // TODO: Probably wait for graceful shutdown first.
            requester.startSession(with: value)
        }
        else {
            requester.endSession()
        }
    }
}

extension CurrentDeviceRecipe: GCKSessionManagerListener {
    func sessionManager(_ sessionManager: GCKSessionManager, willStart session: GCKCastSession) {
        update(session)
    }

    func sessionManager(_ sessionManager: GCKSessionManager, didStart session: GCKCastSession) {
        update(session)
    }

    func sessionManager(_ sessionManager: GCKSessionManager, didResumeCastSession session: GCKCastSession) {
        update(session)
    }

    func sessionManager(
        _ sessionManager: GCKSessionManager,
        didSuspend session: GCKCastSession,
        with reason: GCKConnectionSuspendReason
    ) {
        update(nil)
    }

    func sessionManager(_ sessionManager: GCKSessionManager, didEnd session: GCKCastSession, withError error: (any Error)?) {
        update(session)
    }

    func sessionManager(
        _ sessionManager: GCKSessionManager,
        didFailToStart session: GCKCastSession,
        withError error: any Error
    ) {
        update(nil)
    }
}
