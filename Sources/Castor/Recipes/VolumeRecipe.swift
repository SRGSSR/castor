//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import GoogleCast

final class VolumeRecipe: NSObject, MutableReceiverStateRecipe {
    static let defaultValue: Float = 0

    private let service: GCKSessionManager

    private let update: (Float) -> Void
    private var completion: ((Bool) -> Void)?

    init(service: GCKSessionManager, update: @escaping (Float) -> Void) {
        self.service = service
        self.update = update
        super.init()
        service.add(self)
    }

    static func status(from service: GCKSessionManager) -> Float {
        service.currentCastSession?.currentDeviceVolume ?? defaultValue
    }

    func requestUpdate(to value: Float, completion: @escaping (Bool) -> Void) -> Bool {
        guard let session = service.currentCastSession, !session.isFixedVolume() else { return false }
        self.completion = completion
        let request = session.setDeviceVolume(value)
        request.delegate = self
        return true
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
        update(Self.defaultValue)
    }
}

extension VolumeRecipe: GCKRequestDelegate {
    func requestDidComplete(_ request: GCKRequest) {
        completion?(true)
    }

    func request(_ request: GCKRequest, didAbortWith abortReason: GCKRequestAbortReason) {
        completion?(false)
    }

    func request(_ request: GCKRequest, didFailWithError error: GCKError) {
        completion?(false)
    }
}
