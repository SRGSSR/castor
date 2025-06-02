//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import GoogleCast

final class MutedRecipe: NSObject, SynchronizerRecipe {
    static let defaultValue = false

    let service: GCKSessionManager

    private let update: (DeviceSettings?) -> Void
    private let completion: () -> Void

    var requester: GCKCastSession? {
        service.currentCastSession
    }

    init(service: GCKSessionManager, update: @escaping (DeviceSettings?) -> Void, completion: @escaping () -> Void) {
        self.service = service
        self.update = update
        self.completion = completion
        super.init()
        service.add(self)
    }

    static func status(from requester: GCKCastSession) -> DeviceSettings? {
        .init(volume: requester.currentDeviceVolume, isMuted: requester.currentDeviceMuted)
    }

    static func value(from status: DeviceSettings) -> Bool {
        status.isMuted
    }

    func canMakeRequest(using requester: GCKCastSession) -> Bool {
        requester.traits?.supportsMuting == true
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
