//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import GoogleCast

final class VolumeRecipe: NSObject, MutableSynchronizerRecipe {
    static let defaultValue: Float = 0

    let service: GCKSessionManager

    private let update: (Float?) -> Void
    private let completion: () -> Void

    var requester: GCKCastSession? {
        guard let session = service.currentCastSession else { return nil }
        return !session.isFixedVolume() ? session : nil
    }

    init(service: GCKSessionManager, update: @escaping (Float?) -> Void, completion: @escaping () -> Void) {
        self.service = service
        self.update = update
        self.completion = completion
        super.init()
        service.add(self)
    }

    static func status(from service: GCKSessionManager) -> Float? {
        service.currentCastSession?.currentDeviceVolume
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
        update(volume)
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
