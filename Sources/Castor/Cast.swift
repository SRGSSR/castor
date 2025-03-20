//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import Foundation
import GoogleCast
import SwiftUI

/// This object that handles everything related to Google Cast.
public final class Cast: NSObject, ObservableObject {
    private let context = GCKCastContext.sharedInstance()

    private var currentSession: GCKCastSession? {
        didSet {
            player = .init(remoteMediaClient: currentSession?.remoteMediaClient)
        }
    }

    private var targetDevice: CastDevice?

    /// The current device.
    @Published public var currentDevice: CastDevice? {
        didSet {
            guard let currentDevice else { return }
            moveSession(from: oldValue, to: currentDevice)
        }
    }

    /// The player.
    @Published public private(set) var player: CastPlayer?

    /// The devices found in the local network.
    @Published public private(set) var devices: [CastDevice]

    /// The connection state to a device.
    @Published public private(set) var connectionState: GCKConnectionState

    /// Default initializer.
    override public init() {
        currentSession = context.sessionManager.currentCastSession
        connectionState = context.sessionManager.connectionState
        devices = Self.devices(from: context.discoveryManager)
        currentDevice = currentSession?.device.toCastDevice()
        player = .init(remoteMediaClient: currentSession?.remoteMediaClient)

        super.init()

        context.discoveryManager.add(self)
        context.discoveryManager.startDiscovery()

        context.sessionManager.add(self)

        context.sessionManager.publisher(for: \.connectionState)
            .assign(to: &$connectionState)
    }

    /// Starts a new session with the given device.
    /// - Parameter device: The device to use for this session.
    public func startSession(with device: CastDevice) {
        moveSession(from: currentDevice, to: device)
    }

    private func moveSession(from previousDevice: CastDevice?, to currentDevice: CastDevice) {
        guard previousDevice != currentDevice else { return }
        if previousDevice != nil {
            targetDevice = currentDevice
            endSession()
        }
        else {
            context.sessionManager.startSession(with: currentDevice.rawDevice)
        }
    }

    /// Ends the current session and stops casting if one sender device is connected.
    public func endSession() {
        context.sessionManager.endSession()
    }

    /// Check if the given device if currently casting.
    /// - Parameter device: The device.
    /// - Returns: `true` if the given device is casting, `false` otherwise.
    public func isCasting(on device: CastDevice) -> Bool {
        currentDevice == device
    }
}

extension Cast: GCKDiscoveryManagerListener {
    // swiftlint:disable:next missing_docs
    public func didInsert(_ device: GCKDevice, at index: UInt) {
        devices.insert(device.toCastDevice(), at: Int(index))
    }

    // swiftlint:disable:next missing_docs
    public func didRemove(_ device: GCKDevice, at index: UInt) {
        devices.remove(at: Int(index))
    }

    // swiftlint:disable:next missing_docs
    public func didUpdate(_ device: GCKDevice, at index: UInt, andMoveTo newIndex: UInt) {
        devices.move(from: Int(index), to: Int(index))
    }

    // swiftlint:disable:next missing_docs
    public func didUpdate(_ device: GCKDevice, at index: UInt) {
        devices.remove(at: Int(index))
        devices.insert(device.toCastDevice(), at: Int(index))
    }
}

extension Cast: GCKSessionManagerListener {
    // swiftlint:disable:next missing_docs
    public func sessionManager(_ sessionManager: GCKSessionManager, willStart session: GCKCastSession) {
        currentSession = session
        currentDevice = session.device.toCastDevice()
    }

    // swiftlint:disable:next missing_docs
    public func sessionManager(_ sessionManager: GCKSessionManager, didStart session: GCKCastSession) {
        currentSession = session
    }

    // swiftlint:disable:next missing_docs
    public func sessionManager(_ sessionManager: GCKSessionManager, didResumeCastSession session: GCKCastSession) {
        currentSession = session
    }

    // swiftlint:disable:next missing_docs
    public func sessionManager(
        _ sessionManager: GCKSessionManager,
        didSuspend session: GCKCastSession,
        with reason: GCKConnectionSuspendReason
    ) {
        currentSession = nil
    }

    // swiftlint:disable:next missing_docs
    public func sessionManager(_ sessionManager: GCKSessionManager, didEnd session: GCKCastSession, withError error: (any Error)?) {
        currentSession = sessionManager.currentCastSession
        if let targetDevice {
            sessionManager.startSession(with: targetDevice.rawDevice)
            self.targetDevice = nil
        }
        else {
            currentDevice = nil
        }
    }

    // swiftlint:disable:next missing_docs
    public func sessionManager(
        _ sessionManager: GCKSessionManager,
        didFailToStart session: GCKCastSession,
        withError error: any Error
    ) {
        currentSession = nil
        currentDevice = nil
    }
}

private extension Cast {
    static func devices(from discoveryManager: GCKDiscoveryManager) -> [CastDevice] {
        var devices: [CastDevice] = []
        for index in 0..<discoveryManager.deviceCount {
            devices.append(discoveryManager.device(at: index).toCastDevice())
        }
        return devices
    }
}
