//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import GoogleCast

final class CurrentDeviceRecipe: NSObject, MutableSynchronizerRecipe {
    static let defaultValue: CastDevice? = nil

    private weak var service: GCKSessionManager?

    private let update: (GCKCastSession?) -> Void
    private let completion: (Bool) -> Void

    private var targetDevice: CastDevice?

    init(service: GCKSessionManager, update: @escaping (GCKCastSession?) -> Void, completion: @escaping (Bool) -> Void) {
        self.service = service
        self.update = update
        self.completion = completion
        super.init()
        service.add(self)
    }

    static func status(from service: GCKSessionManager) -> GCKCastSession? {
        service.currentCastSession
    }

    static func value(from session: GCKCastSession) -> CastDevice? {
        session.device.toCastDevice()
    }

    func makeRequest(for value: CastDevice?) -> Bool {
        guard let service else { return false }
        if let value {
            if service.hasConnectedSession() {
                targetDevice = value
                service.endSession()
            }
            else {
                service.startSession(with: value.rawDevice)
            }
        }
        else {
            service.endSession()
        }
        return true
    }
}

extension CurrentDeviceRecipe: GCKSessionManagerListener {
    func sessionManager(_ sessionManager: GCKSessionManager, willStart session: GCKCastSession) {
        update(session)
    }

    func sessionManager(_ sessionManager: GCKSessionManager, didStart session: GCKCastSession) {
        update(session)
        completion(true)
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
        update(sessionManager.currentCastSession)
        if let targetDevice {
            sessionManager.startSession(with: targetDevice.rawDevice)
            self.targetDevice = nil
        }
        else {
            completion(true)
        }
    }

    func sessionManager(
        _ sessionManager: GCKSessionManager,
        didFailToStart session: GCKCastSession,
        withError error: any Error
    ) {
        update(nil)
        completion(false)
    }
}
