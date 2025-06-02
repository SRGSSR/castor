//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import GoogleCast

final class VolumeRecipe: NSObject, SynchronizerRecipe {
    static let defaultValue: Float = 0

    let service: GCKSessionManager

    private let update: (DeviceSettings?) -> Void
    private let completion: () -> Void

    init(service: GCKSessionManager, update: @escaping (DeviceSettings?) -> Void, completion: @escaping () -> Void) {
        self.service = service
        self.update = update
        self.completion = completion
        super.init()
        service.add(self)
    }

    func value(from status: DeviceSettings) -> Float {
        status.volume
    }

    func canMakeRequest(using requester: GCKCastSession) -> Bool {
        service.currentCastSession?.traits?.isFixedVolume() == false
    }

    func makeRequest(for value: Float, using requester: GCKCastSession) {
        let request = requester.setDeviceVolume(value)
        request.delegate = self
    }
}

extension VolumeRecipe: GCKSessionManagerListener {
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

extension VolumeRecipe: GCKRequestDelegate {
    func requestDidComplete(_ request: GCKRequest) {
        completion()
    }
}
