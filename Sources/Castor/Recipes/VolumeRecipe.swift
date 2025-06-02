//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import GoogleCast

final class VolumeRecipe: NSObject, SynchronizerRecipe, GCKSessionManagerListener {
    static let defaultValue: Float = 0

    let service: GCKSessionManager
    private let update: (DeviceSettings?) -> Void

    init(service: GCKSessionManager, update: @escaping (DeviceSettings?) -> Void) {
        self.service = service
        self.update = update
        super.init()
        service.add(self)
    }

    func value(from status: DeviceSettings) -> Float {
        status.volume
    }

    func makeRequest(for value: Float, using requester: GCKCastSession) -> GCKRequest? {
        requester.setDeviceVolume(value)
    }

    func sessionManager(
        _ sessionManager: GCKSessionManager,
        castSession session: GCKCastSession,
        didReceiveDeviceVolume volume: Float,
        muted: Bool
    ) {
        update(.init(volume: volume, isMuted: muted))
    }

    func sessionManager(_ sessionManager: GCKSessionManager, willEnd session: GCKCastSession) {
        update(nil)
    }
}
