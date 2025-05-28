//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import GoogleCast

final class MutedRecipe: NSObject, SynchronizerRecipe, GCKSessionManagerListener {
    static let defaultValue = false

    let service: GCKSessionManager
    private let update: (DeviceSettings?) -> Void

    init(service: GCKSessionManager, update: @escaping (DeviceSettings?) -> Void) {
        self.service = service
        self.update = update
        super.init()
        service.add(self)
    }

    func value(from status: DeviceSettings) -> Bool {
        status.isMuted
    }

    func makeRequest(for value: Bool, using requester: GCKCastSession) -> GCKRequest? {
        requester.setDeviceMuted(value)
    }

    func sessionManager(
        _ sessionManager: GCKSessionManager,
        castSession session: GCKCastSession,
        didReceiveDeviceVolume volume: Float,
        muted: Bool
    ) {
        update(.init(volume: volume, isMuted: muted))
    }
}
