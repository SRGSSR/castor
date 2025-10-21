//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import GoogleCast

struct MainDeviceService: DeviceService {
    typealias VolumeRecipe = MainVolumeRecipe
    typealias MutedRecipe = MainMutedRecipe

    private let sessionManager: GCKSessionManager
    private let session: GCKCastSession

    var device: CastDevice {
        session.device.toCastDevice()
    }

    var volume: Float {
        session.currentDeviceVolume
    }

    var isMuted: Bool {
        session.currentDeviceMuted
    }

    var volumeRange: ClosedRange<Float> {
        session.traits?.volumeRange ?? 0...0
    }

    var canAdjustVolume: Bool {
        !session.isFixedVolume
    }

    var canMute: Bool {
        session.supportsMuting
    }

    init(sessionManager: GCKSessionManager, session: GCKCastSession) {
        self.sessionManager = sessionManager
        self.session = session
    }

    func add(_ listener: GCKSessionManagerListener) {
        sessionManager.add(listener)
    }

    func setVolume(_ volume: Float) -> GCKRequest {
        session.setDeviceVolume(volume)
    }

    func setMuted(_ muted: Bool) -> GCKRequest {
        session.setDeviceMuted(muted)
    }
}
