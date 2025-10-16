//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import CoreMedia
import GoogleCast

final class TargetSeekTimeRecipe: NSObject, MutableReceiverStateRecipe {
    static let defaultValue: CMTime? = nil

    private let service: GCKRemoteMediaClient

    private let update: (GCKMediaStatus?) -> Void
    private let completion: (Bool) -> Void

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

    static func value(from status: GCKMediaStatus?) -> CMTime? {
        // Not seeking when updates occur normally.
        nil
    }

    func requestUpdate(to value: CMTime?) -> Bool {
        guard service.canMakeRequest() else { return false }
        let options = GCKMediaSeekOptions()
        if let value {
            options.interval = value.seconds
        }
        let request = service.seek(with: options)
        request.delegate = self
        return true
    }
}

extension TargetSeekTimeRecipe: @preconcurrency GCKRemoteMediaClientListener {
    func remoteMediaClient(_ client: GCKRemoteMediaClient, didUpdate mediaStatus: GCKMediaStatus?) {
       update(mediaStatus)
    }
}

extension TargetSeekTimeRecipe: @preconcurrency GCKRequestDelegate {
    func requestDidComplete(_ request: GCKRequest) {
        completion(true)
    }

    func request(_ request: GCKRequest, didAbortWith abortReason: GCKRequestAbortReason) {
        completion(false)
    }

    func request(_ request: GCKRequest, didFailWithError error: GCKError) {
        completion(false)
    }
}
