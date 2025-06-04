//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import GoogleCast

final class ShouldPlayRecipe: NSObject, MutableSynchronizerRecipe {
    static let defaultValue = false

    let service: GCKRemoteMediaClient

    private let update: (GCKMediaStatus?) -> Void
    private let completion: () -> Void

    var requester: GCKRemoteMediaClient? {
        service.canMakeRequest() ? service : nil
    }

    init(service: GCKRemoteMediaClient, update: @escaping (GCKMediaStatus?) -> Void, completion: @escaping () -> Void) {
        self.service = service
        self.update = update
        self.completion = completion
        super.init()
        service.add(self)
    }

    static func status(from service: GCKRemoteMediaClient) -> GCKMediaStatus? {
        service.mediaStatus
    }

    static func value(from status: GCKMediaStatus) -> Bool {
        status.playerState == .playing
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
