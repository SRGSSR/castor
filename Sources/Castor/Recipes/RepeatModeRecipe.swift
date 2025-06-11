//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import GoogleCast

final class RepeatModeRecipe: NSObject, MutableSynchronizerRecipe {
    static let defaultValue: CastRepeatMode = .off

    private let service: GCKRemoteMediaClient

    private let update: (GCKMediaStatus?) -> Void
    private var completion: ((Bool) -> Void)?

    init(service: GCKRemoteMediaClient, update: @escaping (GCKMediaStatus?) -> Void) {
        self.service = service
        self.update = update
        super.init()
        service.add(self)
    }

    static func status(from service: GCKRemoteMediaClient) -> GCKMediaStatus? {
        service.mediaStatus
    }

    static func value(from status: GCKMediaStatus?) -> CastRepeatMode {
        guard let status, let mode = CastRepeatMode(rawMode: status.queueRepeatMode) else { return defaultValue }
        return mode
    }

    func makeRequest(for value: CastRepeatMode, completion: @escaping (Bool) -> Void) -> Bool {
        guard service.canMakeRequest() else { return false }
        self.completion = completion
        let request = service.queueSetRepeatMode(value.rawMode())
        request.delegate = self
        return true
    }
}

extension RepeatModeRecipe: GCKRemoteMediaClientListener {
    func remoteMediaClient(_ client: GCKRemoteMediaClient, didUpdate mediaStatus: GCKMediaStatus?) {
        update(mediaStatus)
    }
}

extension RepeatModeRecipe: GCKRequestDelegate {
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
