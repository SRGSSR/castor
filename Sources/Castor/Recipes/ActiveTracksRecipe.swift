//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import GoogleCast

final class ActiveTracksRecipe: NSObject, MutableReceiverStateRecipe {
    static let defaultValue: [CastMediaTrack] = []

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

    static func value(from status: GCKMediaStatus?) -> [CastMediaTrack] {
        status?.activeTracks() ?? []
    }

    func requestUpdate(to value: Value, completion: @escaping (Bool) -> Void) -> Bool {
        guard service.canMakeRequest() else { return false }
        self.completion = completion
        // swiftlint:disable:next legacy_objc_type
        let request = service.setActiveTrackIDs(value.map { NSNumber(value: $0.trackIdentifier) })
        request.delegate = self
        return true
    }
}

extension ActiveTracksRecipe: @preconcurrency GCKRemoteMediaClientListener {
    func remoteMediaClient(_ client: GCKRemoteMediaClient, didUpdate mediaStatus: GCKMediaStatus?) {
        update(mediaStatus)
    }
}

extension ActiveTracksRecipe: @preconcurrency GCKRequestDelegate {
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
