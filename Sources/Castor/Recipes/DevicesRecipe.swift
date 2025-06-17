//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import GoogleCast

final class DevicesRecipe: NSObject, @MainActor ReceiverStateRecipe {
    static let defaultValue: [CastDevice] = []

    private let update: ([CastDevice]) -> Void

    private var devices: [CastDevice] {
        didSet {
            update(devices)
        }
    }

    init(service: GCKDiscoveryManager, update: @escaping ([CastDevice]) -> Void) {
        self.update = update
        self.devices = Self.status(from: service)
        super.init()
        service.add(self)
        service.startDiscovery()
    }

    static func status(from service: GCKDiscoveryManager) -> [CastDevice] {
        var devices: [CastDevice] = []
        for index in 0..<service.deviceCount {
            devices.append(service.device(at: index).toCastDevice())
        }
        return devices
    }
}

extension DevicesRecipe: @preconcurrency GCKDiscoveryManagerListener {
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
