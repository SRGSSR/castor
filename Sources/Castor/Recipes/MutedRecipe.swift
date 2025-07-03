//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import GoogleCast

final class MutedRecipe: NSObject, MutableReceiverStateRecipe {
    static let defaultValue = false

    private let service: GCKSessionManager

    private let update: (Bool) -> Void
    private var completion: ((Bool) -> Void)?

    init(service: GCKSessionManager, update: @escaping (Bool) -> Void) {
        self.service = service
        self.update = update
        super.init()
        service.add(self)
    }

    static func status(from service: GCKSessionManager) -> Bool {
        service.currentCastSession?.currentDeviceMuted ?? defaultValue
    }

    func requestUpdate(to value: Bool, completion: @escaping (Bool) -> Void) -> Bool {
        guard let session = service.currentCastSession, session.supportsMuting else { return false }
        self.completion = completion
        let request = session.setDeviceMuted(value)
        request.delegate = self
        return true
    }
}

extension MutedRecipe: @preconcurrency GCKSessionManagerListener {
    func sessionManager(
        _ sessionManager: GCKSessionManager,
        castSession session: GCKCastSession,
        didReceiveDeviceVolume volume: Float,
        muted: Bool
    ) {
        update(muted)
    }

    func sessionManager(_ sessionManager: GCKSessionManager, willEnd session: GCKCastSession) {
        update(Self.defaultValue)
    }

    func sessionManager(_ sessionManager: GCKSessionManager, didEnd session: GCKCastSession, withError error: (any Error)?) {
        if error != nil {
            update(Self.defaultValue)
        }
    }
}

extension MutedRecipe: @preconcurrency GCKRequestDelegate {
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
