//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import GoogleCast

final class MainMutedRecipe: NSObject, MutableReceiverStateRecipe {
    static let defaultValue = false

    private let service: MainDeviceService

    var update: ((Bool) -> Void)?
    var completion: ((Bool) -> Void)?

    init(service: MainDeviceService) {
        self.service = service
        super.init()
        service.add(self)
    }

    static func status(from service: MainDeviceService) -> Bool {
        service.isMuted
    }

    func requestUpdate(to value: Bool) -> Bool {
        let request = service.setMuted(value)
        request.delegate = self
        return true
    }
}

extension MainMutedRecipe: @preconcurrency GCKSessionManagerListener {
    func sessionManager(
        _ sessionManager: GCKSessionManager,
        castSession session: GCKCastSession,
        didReceiveDeviceVolume volume: Float,
        muted: Bool
    ) {
        update?(muted)
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

extension MainMutedRecipe: @preconcurrency GCKRequestDelegate {
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
