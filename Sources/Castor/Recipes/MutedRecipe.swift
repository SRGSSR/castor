//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import GoogleCast

final class MutedRecipe: NSObject, MutableSynchronizerRecipe {
    static let defaultValue = false

    let service: GCKSessionManager

    private let update: (DeviceSettings?) -> Void
    private let completion: () -> Void

    var requester: GCKCastSession? {
        guard let session = service.currentCastSession else { return nil }
        return session.supportsMuting() ? session : nil
    }

    init(service: GCKSessionManager, update: @escaping (DeviceSettings?) -> Void, completion: @escaping () -> Void) {
        self.service = service
        self.update = update
        self.completion = completion
        super.init()
        service.add(self)
    }

    // TODO: Can likely extract muted directly
    static func status(from service: GCKSessionManager) -> DeviceSettings? {
        guard let session = service.currentCastSession else { return nil }
        return .init(volume: session.currentDeviceVolume, isMuted: session.currentDeviceMuted)
    }

    static func value(from status: DeviceSettings) -> Bool {
        status.isMuted
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
        update(.init(volume: volume, isMuted: muted))
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
