//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import GoogleCast

final class ItemsRecipe: NSObject, MutableSynchronizerRecipe {
    static let defaultValue: [CastPlayerItem] = []

    let service: GCKRemoteMediaClient

    private let update: ([CastPlayerItem]?) -> Void
    private let completion: () -> Void

    var requester: GCKRemoteMediaClient? {
        service.canMakeRequest() ? service : nil
    }

    init(service: GCKRemoteMediaClient, update: @escaping ([CastPlayerItem]?) -> Void, completion: @escaping () -> Void) {
        self.service = service
        self.update = update
        self.completion = completion
        super.init()
        service.mediaQueue.add(self)
    }

    // TODO: Release method, otherwise leak

    static func status(from service: GCKRemoteMediaClient) -> [CastPlayerItem]? {
        nil
    }

    func makeRequest(for value: [CastPlayerItem], using requester: GCKRemoteMediaClient) {

    }
}

extension ItemsRecipe: GCKMediaQueueDelegate {
    
}
