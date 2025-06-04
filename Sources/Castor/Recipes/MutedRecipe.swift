//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import GoogleCast

final class MutedRecipe: NSObject, MutableSynchronizerRecipe {
    static let defaultValue = false

    let service: GCKSessionManager

    // swiftlint:disable:next discouraged_optional_boolean
    private let update: (Bool?) -> Void
    private let completion: () -> Void

    var requester: GCKCastSession? {
        guard let session = service.currentCastSession else { return nil }
        return session.supportsMuting() ? session : nil
    }

    // swiftlint:disable:next discouraged_optional_boolean
    init(service: GCKSessionManager, update: @escaping (Bool?) -> Void, completion: @escaping () -> Void) {
        self.service = service
        self.update = update
        self.completion = completion
        super.init()
        service.add(self)
    }

    // swiftlint:disable:next discouraged_optional_boolean
    static func status(from service: GCKSessionManager) -> Bool? {
        service.currentCastSession?.currentDeviceMuted
    }

    func makeRequest(for value: Bool, using requester: GCKCastSession) {
        let request = requester.setDeviceMuted(value)
        request.delegate = self
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
        completion()
    }
}
