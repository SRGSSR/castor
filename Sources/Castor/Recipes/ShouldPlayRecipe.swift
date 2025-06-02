//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import GoogleCast

final class ShouldPlayRecipe: NSObject, SynchronizerRecipe {
    static let defaultValue = false

    let service: GCKRemoteMediaClient

    private let update: (GCKMediaStatus?) -> Void
    private let completion: () -> Void

    var requester: GCKRemoteMediaClient? {
        service
    }

    init(service: GCKRemoteMediaClient, update: @escaping (GCKMediaStatus?) -> Void, completion: @escaping () -> Void) {
        self.service = service
        self.update = update
        self.completion = completion
        super.init()
        service.add(self)
    }

    func status(from requester: GCKRemoteMediaClient) -> GCKMediaStatus? {
        requester.mediaStatus
    }

    func value(from status: GCKMediaStatus) -> Bool {
        status.playerState == .playing
    }

    func canMakeRequest(using requester: GCKRemoteMediaClient) -> Bool {
        requester.canMakeRequest()
    }

    func makeRequest(for value: Bool, using requester: GCKRemoteMediaClient) {
        let request = Self.request(for: value, using: requester)
        request.delegate = self
    }

    private static func request(for value: Bool, using requester: GCKRemoteMediaClient) -> GCKRequest {
        if value {
            return requester.play()
        }
        else {
            return requester.pause()
        }
    }
}

extension ShouldPlayRecipe: GCKRemoteMediaClientListener {
    func remoteMediaClient(_ client: GCKRemoteMediaClient, didUpdate mediaStatus: GCKMediaStatus?) {
        update(mediaStatus)
    }
}

extension ShouldPlayRecipe: GCKRequestDelegate {
    func requestDidComplete(_ request: GCKRequest) {
        completion()
    }
}
