//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import GoogleCast

/// An object representing a receiver device.
@MainActor
public struct CastDevice: Hashable {
    let rawDevice: GCKDevice

    /// The device's friendly name.
    public var name: String? {
        rawDevice.friendlyName
    }

    /// The device type.
    public var type: GCKDeviceType {
        rawDevice.type
    }

    /// The status text reported by the currently running receiver application.
    public var status: String? {
        guard let status = rawDevice.statusText, !status.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return nil }
        return status
    }

    fileprivate init(from device: GCKDevice) {
        self.rawDevice = device
    }

    // swiftlint:disable:next missing_docs
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.rawDevice.isSameDevice(as: rhs.rawDevice)
    }
}

extension GCKDevice {
    @MainActor
    func toCastDevice() -> CastDevice {
        .init(from: self)
    }
}
