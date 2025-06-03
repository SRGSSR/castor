//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import CoreMedia
import GoogleCast

final class TargetSeekRecipe: NSObject, MutableSynchronizerRecipe {
    static let defaultValue: CMTime? = nil

    let service: GCKRemoteMediaClient

    private let update: (GCKMediaStatus?) -> Void
    private let completion: () -> Void

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

    static func value(from status: GCKMediaStatus) -> CMTime? {
        nil
    }

    func canMakeRequest(using service: GCKRemoteMediaClient) -> Bool {
        service.canMakeRequest()
    }

    func makeRequest(for value: CMTime?, using service: GCKRemoteMediaClient) {
        let options = GCKMediaSeekOptions()
        if let value {
            options.interval = value.seconds
        }
        let request = service.seek(with: options)
        request.delegate = self
    }
}

extension TargetSeekRecipe: GCKRemoteMediaClientListener {
    func remoteMediaClient(_ client: GCKRemoteMediaClient, didUpdate mediaStatus: GCKMediaStatus?) {
       update(mediaStatus)
    }
}

extension TargetSeekRecipe: GCKRequestDelegate {
    func requestDidComplete(_ request: GCKRequest) {
        completion()
    }
}
