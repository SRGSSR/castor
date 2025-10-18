//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import GoogleCast

/// An object that represents a multi-zone Cast receiver device.
///
/// Multi-zone devices are part of a Cast device group, allowing synchronized playback across multiple receivers.
public struct CastMultizoneDevice: Hashable {
    let rawDevice: GCKMultizoneDevice

    /// The device's friendly name.
    public var name: String? {
        rawDevice.friendlyName
    }

    fileprivate init(from device: GCKMultizoneDevice) {
        self.rawDevice = device
    }

    // swiftlint:disable:next missing_docs
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.rawDevice.deviceID == rhs.rawDevice.deviceID
    }
}

extension CastMultizoneDevice {
    static func name(for device: CastMultizoneDevice?) -> String {
        device?.name ?? String(localized: "Unknown", bundle: .module, comment: "Generic name for a Cast device")
    }
}

extension GCKMultizoneDevice {
    func toCastDevice() -> CastMultizoneDevice {
        .init(from: self)
    }
}
