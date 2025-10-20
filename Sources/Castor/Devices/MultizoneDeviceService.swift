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

    let device: CastMultizoneDevice

    private var rawDevice: GCKMultizoneDevice {
        device.rawDevice
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

    init?(session: GCKCastSession?, device: CastMultizoneDevice) {
        guard let session else { return nil }
        self.session = session
        self.device = device
    }

    func add(_ listener: GCKCastDeviceStatusListener) {
        session.requestMultizoneStatus()
        session.add(listener)
    }

    func setVolume(_ volume: Float) -> GCKRequest {
        session.setDeviceVolume(volume, for: rawDevice)
    }

    func setMuted(_ muted: Bool) -> GCKRequest {
        session.setDeviceMuted(muted, for: rawDevice)
    }
}
