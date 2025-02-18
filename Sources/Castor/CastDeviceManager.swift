//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import Foundation
import GoogleCast
import SwiftUI

/// This object handles the discovery of receiver devices.
public final class CastDeviceManager: NSObject, ObservableObject {
    private let context = GCKCastContext.sharedInstance()
    private var currentCastSession: GCKCastSession?

    @Published private var currentDevice: CastDevice?

    @Published public private(set) var devices: [CastDevice]
    @Published public private(set) var connectionState: GCKConnectionState

    /// Default initializer.
    override public init() {
        currentCastSession = context.sessionManager.currentCastSession
        connectionState = context.sessionManager.connectionState
        devices = Self.devices(from: context.discoveryManager)
        currentDevice = currentCastSession?.device.toCastDevice()

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
        guard currentDevice != device else { return }
        currentDevice = device
        endSession()
        context.sessionManager.startSession(with: device.rawDevice)
    }

    /// Ends the current session and stops casting if one sender device is connected.
    public func endSession() {
        context.sessionManager.endSession()
    }

    /// A binding to read and write the current device selection.
    /// - Returns: The device binding.
    public func device() -> Binding<CastDevice?> {
        .init {
            self.currentDevice
        } set: { device in
            if let device {
                self.startSession(with: device)
            }
        }
    }

    /// Check if the given device if currently casting.
    /// - Parameter device: The device.
    /// - Returns: `true` if the given device is casting, `false` otherwise.
    public func isCasting(on device: CastDevice) -> Bool {
        currentDevice == device
    }
}

extension CastDeviceManager: GCKDiscoveryManagerListener {
    public func didInsert(_ device: GCKDevice, at index: UInt) {
        devices.insert(device.toCastDevice(), at: Int(index))
    }

    public func didRemove(_ device: GCKDevice, at index: UInt) {
        devices.remove(at: Int(index))
    }

    public func didUpdate(_ device: GCKDevice, at index: UInt, andMoveTo newIndex: UInt) {
        devices.move(from: Int(index), to: Int(index))
    }

    public func didUpdate(_ device: GCKDevice, at index: UInt) {
        devices.remove(at: Int(index))
        devices.insert(device.toCastDevice(), at: Int(index))
    }
}

extension CastDeviceManager: GCKSessionManagerListener {
    public func sessionManager(_ sessionManager: GCKSessionManager, willStart session: GCKCastSession) {
        currentCastSession = session
        currentDevice = session.device.toCastDevice()
    }

    public func sessionManager(_ sessionManager: GCKSessionManager, didEnd session: GCKCastSession, withError error: (any Error)?) {
        currentCastSession = sessionManager.currentCastSession
        if let currentDevice, session.device.toCastDevice() != currentDevice {
            sessionManager.startSession(with: currentDevice.rawDevice)
        }
        else {
            currentDevice = nil
        }
    }

    public func sessionManager(
        _ sessionManager: GCKSessionManager,
        didFailToStart session: GCKCastSession,
        withError error: any Error
    ) {
        currentCastSession = nil
        currentDevice = nil
    }
}

private extension CastDeviceManager {
    static func devices(from discoveryManager: GCKDiscoveryManager) -> [CastDevice] {
        var devices: [CastDevice] = []
        for index in 0..<discoveryManager.deviceCount {
            devices.append(discoveryManager.device(at: index).toCastDevice())
        }
        return devices
    }
}
