//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.

import GoogleCast

final class DevicesRecipe: NSObject, MutableSynchronizerRecipe {
    static let defaultValue: [CastDevice] = []

    let service: GCKDiscoveryManager

    private let update: ([CastDevice]) -> Void
    private let completion: () -> Void

    private var devices: [CastDevice] = [] {
        didSet {
            update(devices)
        }
    }

    var requester: GCKDiscoveryManager? {
        service
    }

    init(service: GCKDiscoveryManager, update: @escaping ([CastDevice]?) -> Void, completion: @escaping () -> Void) {
        self.service = service
        self.update = update
        self.completion = completion
        super.init()
        service.add(self)
        service.startDiscovery()
    }

    static func status(from requester: GCKDiscoveryManager) -> [CastDevice]? {
        var devices: [CastDevice] = []
        for index in 0..<requester.deviceCount {
            devices.append(requester.device(at: index).toCastDevice())
        }
        return devices
    }

    static func value(from status: [CastDevice]) -> [CastDevice] {
        status
    }

    func canMakeRequest(using requester: GCKDiscoveryManager) -> Bool {
        false
    }

    func makeRequest(for value: [CastDevice], using requester: GCKDiscoveryManager) {}
}

extension DevicesRecipe: GCKDiscoveryManagerListener {
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
