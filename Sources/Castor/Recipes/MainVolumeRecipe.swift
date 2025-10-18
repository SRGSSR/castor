//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import GoogleCast

final class MainVolumeRecipe: NSObject, MutableReceiverStateRecipe {
    static let defaultValue: Float = 0

    private let service: MainDeviceService

    var update: ((Float) -> Void)?
    var completion: ((Bool) -> Void)?

    init(service: MainDeviceService) {
        self.service = service
        super.init()
        service.add(self)
    }

    static func status(from service: MainDeviceService) -> Float {
        service.volume
    }

    func requestUpdate(to value: Float) -> Bool {
        let request = service.setVolume(value)
        request.delegate = self
        return true
    }
}

extension MainVolumeRecipe: @preconcurrency GCKSessionManagerListener {
    func sessionManager(
        _ sessionManager: GCKSessionManager,
        castSession session: GCKCastSession,
        didReceiveDeviceVolume volume: Float,
        muted: Bool
    ) {
        update?(volume)
    }

    func sessionManager(_ sessionManager: GCKSessionManager, willEnd session: GCKCastSession) {
        update?(Self.defaultValue)
    }

    func sessionManager(_ sessionManager: GCKSessionManager, didEnd session: GCKCastSession, withError error: (any Error)?) {
        if error != nil {
            update?(Self.defaultValue)
        }
    }
}

extension MainVolumeRecipe: @preconcurrency GCKRequestDelegate {
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
