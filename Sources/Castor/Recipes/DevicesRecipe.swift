//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import GoogleCast

final class DevicesRecipe: NSObject, ReceiverStateRecipe {
    static let defaultValue: [CastDevice] = []

    var update: (([CastDevice]) -> Void)?
    private let service: GCKDiscoveryManager

    private var devices: [CastDevice] = [] {
        didSet {
            update?(devices)
        }
    }

    init(service: GCKDiscoveryManager) {
        self.service = service
        super.init()
        service.add(self)
        service.startDiscovery()
    }

    static func status(from service: GCKDiscoveryManager) -> [CastDevice] {
        Self.devices(from: service)
    }

    private static func devices(from service: GCKDiscoveryManager) -> [CastDevice] {
        var devices: [CastDevice] = []
        for index in 0..<service.deviceCount {
            devices.append(service.device(at: index).toCastDevice())
        }
        return devices
    }

    private func updateDevices() {
        devices = Self.devices(from: service)
    }
}

extension DevicesRecipe: @preconcurrency GCKDiscoveryManagerListener {
    func didInsert(_ device: GCKDevice, at index: UInt) {
        updateDevices()
    }

    func didRemove(_ device: GCKDevice, at index: UInt) {
        updateDevices()
    }

    func didUpdate(_ device: GCKDevice, at index: UInt, andMoveTo newIndex: UInt) {
        updateDevices()
    }

    func didUpdate(_ device: GCKDevice, at index: UInt) {
        updateDevices()
    }
}
