//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import GoogleCast

struct MultizoneDeviceService: DeviceService {
    typealias VolumeRecipe = MultizoneVolumeRecipe
    typealias MutedRecipe = MultizoneMutedRecipe

    private let session: GCKCastSession
    private let rawDevice: GCKMultizoneDevice

    var device: CastMultizoneDevice {
        rawDevice.toCastDevice()
    }

    var volume: Float {
        rawDevice.volumeLevel
    }

    var isMuted: Bool {
        rawDevice.muted
    }

    var volumeRange: ClosedRange<Float> {
        0...1
    }

    var canAdjustVolume: Bool {
        true
    }

    var canMute: Bool {
        true
    }

    init(session: GCKCastSession, rawDevice: GCKMultizoneDevice) {
        self.session = session
        self.rawDevice = rawDevice
    }

    func add(_ listener: GCKCastDeviceStatusListener) {
        session.add(listener)
    }

    func setVolume(_ volume: Float) -> GCKRequest {
        session.setDeviceVolume(volume, for: rawDevice)
    }

    func setMuted(_ muted: Bool) -> GCKRequest {
        session.setDeviceMuted(muted, for: rawDevice)
    }
}
