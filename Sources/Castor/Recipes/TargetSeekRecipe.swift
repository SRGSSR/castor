//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import CoreMedia
import GoogleCast

final class TargetSeekRecipe: NSObject, SynchronizerRecipe, GCKRemoteMediaClientListener {
    static let defaultValue: CMTime? = nil

    let service: GCKRemoteMediaClient
    private let update: (GCKMediaStatus?) -> Void

    init(service: GCKRemoteMediaClient, update: @escaping (GCKMediaStatus?) -> Void) {
        self.service = service
        self.update = update
        super.init()
        service.add(self)
    }

    func value(from status: GCKMediaStatus) -> CMTime? {
        nil
    }

    func makeRequest(for value: CMTime?, using requester: GCKRemoteMediaClient) -> GCKRequest? {
        let options = GCKMediaSeekOptions()
        if let value {
            options.interval = value.seconds
        }
        return requester.seek(with: options)
    }

    func remoteMediaClient(_ client: GCKRemoteMediaClient, didUpdate mediaStatus: GCKMediaStatus?) {
       update(mediaStatus)
    }
}
