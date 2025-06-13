//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import GoogleCast

final class ShouldPlayRecipe: NSObject, MutableReceiverStateRecipe {
    static let defaultValue = false

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

    static func value(from status: GCKMediaStatus?) -> Bool {
        status?.playerState == .playing
    }

    private static func request(for value: Bool, using remoteMediaClient: GCKRemoteMediaClient) -> GCKRequest {
        value ? remoteMediaClient.play() : remoteMediaClient.pause()
    }

    func requestUpdate(to value: Bool, completion: @escaping (Bool) -> Void) -> Bool {
        guard service.canMakeRequest() else { return false }
        self.completion = completion
        let request = Self.request(for: value, using: service)
        request.delegate = self
        return true
    }
}

extension ShouldPlayRecipe: GCKRemoteMediaClientListener {
    func remoteMediaClient(_ client: GCKRemoteMediaClient, didUpdate mediaStatus: GCKMediaStatus?) {
        update(mediaStatus)
    }
}

extension ShouldPlayRecipe: GCKRequestDelegate {
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
