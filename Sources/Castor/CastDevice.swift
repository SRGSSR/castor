//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import GoogleCast

/// An object representing a receiver device.
public struct CastDevice: Hashable {
    let rawDevice: GCKDevice

    public var name: String? {
        rawDevice.friendlyName
    }

    public var type: GCKDeviceType {
        rawDevice.type
    }

    public var status: String? {
        rawDevice.statusText
    }

    fileprivate init(from device: GCKDevice) {
        self.rawDevice = device
    }

    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.rawDevice.isSameDevice(as: rhs.rawDevice)
    }
}

extension GCKDevice {
    func toCastDevice() -> CastDevice {
        .init(from: self)
    }
}
