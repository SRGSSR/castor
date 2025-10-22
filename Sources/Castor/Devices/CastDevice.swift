//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import GoogleCast

/// An object that represents a Cast receiver device.
public struct CastDevice: Hashable {
    let rawDevice: GCKDevice

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

extension CastDevice: CastReceiver {
    // swiftlint:disable:next missing_docs
    public var name: String? {
        rawDevice.friendlyName
    }
}

extension CastDevice {
    static func imageName(for device: CastDevice) -> String {
        switch device.type {
        case .TV:
            "tv"
        case .speaker:
            "hifispeaker"
        case .speakerGroup:
            "hifispeaker.2"
        default:
            "tv.and.hifispeaker.fill"
        }
    }

    static func route(to device: CastDevice?) -> String {
        String(localized: "Connected to \(name(for: device))", bundle: .module, comment: "Connected receiver (device name as wildcard)")
    }
}

extension GCKDevice {
    func toCastDevice() -> CastDevice {
        .init(from: self)
    }
}
