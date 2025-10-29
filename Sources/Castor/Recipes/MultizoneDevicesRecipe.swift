//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import GoogleCast

final class MultizoneDevicesRecipe: NSObject, ReceiverStateRecipe {
    static var defaultValue: [CastMultizoneDevice] = []

    var update: (([CastMultizoneDevice]) -> Void)?

    private var currentSession: GCKCastSession? {
        willSet {
            guard currentSession != newValue else { return }
            currentSession?.remove(self)
            devices = []
        }
        didSet {
            guard currentSession != oldValue else { return }
            currentSession?.add(self)
            currentSession?.requestMultizoneStatus()
        }
    }

    private var devices: [CastMultizoneDevice] = [] {
        didSet {
            update?(devices)
        }
    }

    init(service: GCKSessionManager) {
        super.init()

        service.add(self)

        service.currentCastSession?.add(self)
        service.currentCastSession?.requestMultizoneStatus()
    }

    static func status(from service: GCKSessionManager) -> [CastMultizoneDevice] {
        []
    }
}

extension MultizoneDevicesRecipe: @preconcurrency GCKSessionManagerListener {
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

extension MultizoneDevicesRecipe: @preconcurrency GCKCastDeviceStatusListener {
    func castSession(_ castSession: GCKCastSession, didReceive multizoneStatus: GCKMultizoneStatus) {
        devices = multizoneStatus.devices.map { $0.toCastDevice() }
    }
}
