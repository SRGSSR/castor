//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import GoogleCast

final class MultizoneMutedRecipe: NSObject, MutableReceiverStateRecipe {
    static let defaultValue = false

    private let service: MultizoneDeviceService

    var update: ((Bool) -> Void)?
    var completion: ((Bool) -> Void)?

    private var currentSession: GCKCastSession? {
        willSet {
            guard currentSession != newValue else { return }
            currentSession?.remove(self)
        }
        didSet {
            guard currentSession != oldValue else { return }
            currentSession?.add(self)
        }
    }

    init(service: MultizoneDeviceService) {
        let sessionManager = service.sessionManager
        let session = sessionManager.currentCastSession

        self.service = service
        self.currentSession = session

        super.init()

        sessionManager.add(self)
        session?.add(self)
    }

    static func status(from service: MultizoneDeviceService) -> Bool {
        service.rawDevice.muted
    }

    func requestUpdate(to value: Bool) -> Bool {
        guard let currentSession else { return false }
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(completeRequest), object: nil)
        perform(#selector(completeRequest), with: nil, afterDelay: 0.1)
        currentSession.setDeviceMuted(value, for: service.rawDevice)
        return true
    }

    @objc
    private func completeRequest() {
        completion?(true)
    }
}

extension MultizoneMutedRecipe: @preconcurrency GCKSessionManagerListener {
    func sessionManager(_ sessionManager: GCKSessionManager, didStart session: GCKCastSession) {
        currentSession = session
    }

    func sessionManager(_ sessionManager: GCKSessionManager, didResumeCastSession session: GCKCastSession) {
        currentSession = session
    }

    func sessionManager(_ sessionManager: GCKSessionManager, didSuspend session: GCKCastSession, with reason: GCKConnectionSuspendReason) {
        currentSession = nil
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

extension MultizoneMutedRecipe: @preconcurrency GCKCastDeviceStatusListener {
    func castSession(_ castSession: GCKCastSession, didUpdate device: GCKMultizoneDevice) {
        guard device == service.rawDevice else { return }
        update?(device.muted)
    }
}
