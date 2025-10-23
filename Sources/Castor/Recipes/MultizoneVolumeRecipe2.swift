//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import GoogleCast

final class MultizoneVolumeRecipe2: NSObject, MutableReceiverStateRecipe {
    static let defaultValue: Float = 0

    private let service: MultizoneDeviceService2

    var update: ((Float) -> Void)?
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

    init(service: MultizoneDeviceService2) {
        self.service = service
        super.init()
        service.sessionManager.add(self)
    }

    static func status(from service: MultizoneDeviceService2) -> Float {
        service.device.volumeLevel
    }

    func requestUpdate(to value: Float) -> Bool {
        guard let currentSession else { return false }
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(completeRequest), object: nil)
        perform(#selector(completeRequest), with: nil, afterDelay: 0.1)
        currentSession.setDeviceVolume(value, for: service.device)
        return true
    }

    @objc
    private func completeRequest() {
        completion?(true)
    }
}

extension MultizoneVolumeRecipe2: @preconcurrency GCKSessionManagerListener {
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
        currentSession = nil
    }
}

extension MultizoneVolumeRecipe2: @preconcurrency GCKCastDeviceStatusListener {
    func castSession(_ castSession: GCKCastSession, didUpdate device: GCKMultizoneDevice) {
        guard device == service.device else { return }
        update?(device.volumeLevel)
    }
}
