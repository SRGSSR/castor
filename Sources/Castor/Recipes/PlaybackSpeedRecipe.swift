//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import GoogleCast

final class PlaybackSpeedRecipe: NSObject, MutableReceiverStateRecipe {
    static let defaultValue: Float = 1

    private let service: GCKRemoteMediaClient

    private let update: (GCKMediaStatus?) -> Void
    private var completion: ((Bool) -> Void)?

    init(service: GCKRemoteMediaClient, update: @escaping (GCKMediaStatus?) -> Void, completion: @escaping (Bool) -> Void) {
        self.service = service
        self.update = update
        self.completion = completion
        super.init()
        service.add(self)
    }

    static func status(from service: GCKRemoteMediaClient) -> GCKMediaStatus? {
        service.mediaStatus
    }

    static func value(from status: GCKMediaStatus?) -> Float {
        status?.playbackRate ?? defaultValue
    }

    func requestUpdate(to value: Float) -> Bool {
        guard service.canMakeRequest() else { return false }
        let request = service.setPlaybackRate(value)
        request.delegate = self
        return true
    }
}

extension PlaybackSpeedRecipe: @preconcurrency GCKRemoteMediaClientListener {
    func remoteMediaClient(_ client: GCKRemoteMediaClient, didUpdate mediaStatus: GCKMediaStatus?) {
        // Trigger an update to an appropriate speed if required. This most notably avoids speeds > 1 being applied
        // to livestreams during playlist item transitions.
        if let mediaStatus, mediaStatus.mediaInformation?.streamType == .live, mediaStatus.playbackRate != Self.defaultValue {
            client.setPlaybackRate(Self.defaultValue)
        }
        else {
            update(mediaStatus)
        }
    }
}

extension PlaybackSpeedRecipe: @preconcurrency GCKRequestDelegate {
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
