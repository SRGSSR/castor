//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation
import GoogleCast

/// This object handles the discovery of receiver devices.
public final class CastDeviceManager: NSObject, ObservableObject {
    private let context = GCKCastContext.sharedInstance()

    @Published public private(set) var devices: [GCKDevice]

    /// Default initializer.
    override public init() {
        devices = Self.devices(from: context.discoveryManager)
        super.init()
        context.discoveryManager.add(self)
        context.discoveryManager.startDiscovery()
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

private extension CastDeviceManager {
    static func devices(from discoveryManager: GCKDiscoveryManager) -> [GCKDevice] {
        var devices: [GCKDevice] = []
        for index in 0..<discoveryManager.deviceCount {
            devices.append(discoveryManager.device(at: index))
        }
        return devices
    }
}
