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

    @Published public private(set) var devices: [GCKDevice]
    @Published public private(set) var connectionState: GCKConnectionState

    /// The current device.
    @Published public private(set) var device: GCKDevice?

    /// Default initializer.
    override public init() {
        currentCastSession = context.sessionManager.currentCastSession
        connectionState = context.sessionManager.connectionState
        devices = Self.devices(from: context.discoveryManager)
        device = currentCastSession?.device

        super.init()

        context.discoveryManager.add(self)
        context.discoveryManager.startDiscovery()

        context.sessionManager.add(self)

        context.sessionManager.publisher(for: \.connectionState)
            .assign(to: &$connectionState)
    }

    /// Starts a new session with the given device.
    /// - Parameter device: The device to use for this session.
    public func startSession(with device: GCKDevice) {
        context.sessionManager.startSession(with: device)
    }

    /// Ends the current session and stops casting if one sender device is connected.
    /// - Parameter stopCasting: Whether casting on the receiver should stop when the session ends.
    public func endSession(stopCasting: Bool = false) {
        context.sessionManager.endSessionAndStopCasting(stopCasting)
    }

    /// A binding to read and write the current device selection.
    /// - Parameter stopCasting: Whether casting on the receiver should stop when the session ends.
    /// - Returns: The device binding.
    public func device(stopCasting: Bool = false) -> Binding<GCKDevice?> {
        .init {
            self.device
        } set: { device in
            if let device, self.device != device {
                self.device = device
                self.endSession(stopCasting: stopCasting)
                self.startSession(with: device)
            }
        }
    }
}

extension CastDeviceManager: GCKDiscoveryManagerListener {
    public func didInsert(_ device: GCKDevice, at index: UInt) {
        devices.insert(device, at: Int(index))
    }

    public func didRemove(_ device: GCKDevice, at index: UInt) {
        devices.remove(at: Int(index))
    }

    public func didUpdate(_ device: GCKDevice, at index: UInt, andMoveTo newIndex: UInt) {
        devices.move(from: Int(index), to: Int(index))
    }

    public func didUpdate(_ device: GCKDevice, at index: UInt) {
        devices.remove(at: Int(index))
        devices.insert(device, at: Int(index))
    }
}

extension CastDeviceManager: GCKSessionManagerListener {
    public func sessionManager(_ sessionManager: GCKSessionManager, willStart session: GCKCastSession) {
        currentCastSession = session
    }

    public func sessionManager(_ sessionManager: GCKSessionManager, didEnd session: GCKCastSession, withError error: (any Error)?) {
        currentCastSession = sessionManager.currentCastSession
        if let device, session.device != device {
            startSession(with: device)
        }
        else {
            device = nil
        }
    }

    public func sessionManager(
        _ sessionManager: GCKSessionManager,
        didFailToStart session: GCKSession,
        withError error: any Error
    ) {
        currentCastSession = sessionManager.currentCastSession
    }
}

private extension CastDeviceManager {
    static func devices(from discoveryManager: GCKDiscoveryManager) -> [GCKDevice] {
        var devices: [GCKDevice] = []
        for index in 0..<discoveryManager.deviceCount {
            devices.append(discoveryManager.device(at: index))
        }
        return devices
    }
}
