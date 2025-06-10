//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import CoreMedia
import GoogleCast

final class TargetSeekRecipe: NSObject, MutableSynchronizerRecipe {
    static let defaultValue: CMTime? = nil

    private weak var service: GCKRemoteMediaClient?

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

    // TODO: This feels out of place
    static func value(from status: GCKMediaStatus) -> CMTime? {
        nil
    }

    func makeRequest(for value: CMTime?) -> Bool {
        guard let service, service.canMakeRequest() else { return false }
        let options = GCKMediaSeekOptions()
        if let value {
            options.interval = value.seconds
        }
        let request = service.seek(with: options)
        request.delegate = self
        return true
    }
}

extension TargetSeekRecipe: GCKRemoteMediaClientListener {
    func remoteMediaClient(_ client: GCKRemoteMediaClient, didUpdate mediaStatus: GCKMediaStatus?) {
       update(mediaStatus)
    }
}

extension TargetSeekRecipe: GCKRequestDelegate {
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
