//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import GoogleCast

final class MutedRecipe: NSObject, MutableSynchronizerRecipe {
    static let defaultValue = false

    private let service: GCKSessionManager

    // swiftlint:disable:next discouraged_optional_boolean
    private let update: (Bool?) -> Void
    private var completion: ((Bool) -> Void)?

    // swiftlint:disable:next discouraged_optional_boolean
    init(service: GCKSessionManager, update: @escaping (Bool?) -> Void) {
        self.service = service
        self.update = update
        super.init()
        service.add(self)
    }

    // swiftlint:disable:next discouraged_optional_boolean
    static func status(from service: GCKSessionManager) -> Bool? {
        service.currentCastSession?.currentDeviceMuted
    }

    func makeRequest(for value: Bool, completion: @escaping (Bool) -> Void) -> Bool {
        guard let session = service.currentCastSession, session.supportsMuting() else { return false }
        let request = session.setDeviceMuted(value)
        request.delegate = self
        return true
    }
}

extension MutedRecipe: GCKSessionManagerListener {
    func sessionManager(
        _ sessionManager: GCKSessionManager,
        castSession session: GCKCastSession,
        didReceiveDeviceVolume volume: Float,
        muted: Bool
    ) {
        update(muted)
    }

    func sessionManager(_ sessionManager: GCKSessionManager, willEnd session: GCKCastSession) {
        update(nil)
    }
}

extension MutedRecipe: GCKRequestDelegate {
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
