//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import GoogleCast

final class ContextRecipe: NSObject, ReceiverStateRecipe {
    static let defaultValue: CastContext = .init(devices: [], multizoneDevices: [], session: nil)

    // ReceiverStateRecipe requirement: callback to publish status updates
    var update: ((CastContext) -> Void)?

    private var devices: [CastDevice] {
        didSet {
            update?(.init(devices: devices, multizoneDevices: multizoneDevices, session: session))
        }
    }

    private var multizoneDevices: [CastMultizoneDevice] = [] {
        didSet {
            update?(.init(devices: devices, multizoneDevices: multizoneDevices, session: session))
        }
    }

    private var session: GCKCastSession? {
        willSet {
            session?.remove(self)
        }
        didSet {
            session?.add(self)
            multizoneDevices = []
        }
    }

    init(service: GCKCastContext) {
        let discoveryManager = service.discoveryManager
        let sessionManager = service.sessionManager

        self.devices = Self.devices(from: discoveryManager)
        self.session = sessionManager.currentCastSession

        super.init()

        discoveryManager.add(self)
        discoveryManager.startDiscovery()

        sessionManager.add(self)
    }

    static func status(from service: GCKCastContext) -> CastContext {
        .init(
            devices: devices(from: service.discoveryManager),
            multizoneDevices: [],
            session: service.sessionManager.currentCastSession
        )
    }

    private static func devices(from discoveryManager: GCKDiscoveryManager) -> [CastDevice] {
        var devices: [CastDevice] = []
        for index in 0..<discoveryManager.deviceCount {
            devices.append(discoveryManager.device(at: index).toCastDevice())
        }
        return devices
    }
}

extension ContextRecipe: @preconcurrency GCKDiscoveryManagerListener {
    func didInsert(_ device: GCKDevice, at index: UInt) {
        devices.insert(device.toCastDevice(), at: Int(index))
    }

    func didRemove(_ device: GCKDevice, at index: UInt) {
        devices.remove(at: Int(index))
    }

    func didUpdate(_ device: GCKDevice, at index: UInt, andMoveTo newIndex: UInt) {
        devices.move(from: Int(index), to: Int(newIndex))
    }

    func didUpdate(_ device: GCKDevice, at index: UInt) {
        devices.remove(at: Int(index))
        devices.insert(device.toCastDevice(), at: Int(index))
    }
}

extension ContextRecipe: @preconcurrency GCKCastDeviceStatusListener {
    func castSession(_ castSession: GCKCastSession, didReceive multizoneStatus: GCKMultizoneStatus) {
        multizoneDevices = multizoneStatus.devices.map { $0.toCastDevice() }
    }
}

extension ContextRecipe: @preconcurrency GCKSessionManagerListener {
    func sessionManager(_ sessionManager: GCKSessionManager, willStart session: GCKCastSession) {
        self.session = session
    }

    func sessionManager(_ sessionManager: GCKSessionManager, didStart session: GCKCastSession) {
        self.session = session
    }

    func sessionManager(_ sessionManager: GCKSessionManager, didResumeCastSession session: GCKCastSession) {
        self.session = session
    }

    func sessionManager(
        _ sessionManager: GCKSessionManager,
        didSuspend session: GCKCastSession,
        with reason: GCKConnectionSuspendReason
    ) {
        self.session = nil
    }

    func sessionManager(_ sessionManager: GCKSessionManager, didEnd session: GCKCastSession, withError error: (any Error)?) {
        self.session = sessionManager.currentCastSession
    }

    func sessionManager(
        _ sessionManager: GCKSessionManager,
        didFailToStart session: GCKCastSession,
        withError error: any Error
    ) {
        // TODO: sessionManager.currentCastSession ?
        self.session = nil
    }
}
