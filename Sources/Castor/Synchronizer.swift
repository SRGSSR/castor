//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import GoogleCast

final class Synchronizer<Value>: NSObject, GCKRemoteMediaClientListener, GCKRequestDelegate {
    private let remoteMediaClient: GCKRemoteMediaClient
    private let get: (GCKMediaStatus?) -> Value
    private let set: (GCKRemoteMediaClient, Value) -> GCKRequest

    @Published private(set) var value: Value

    private weak var currentRequest: GCKRequest?
    private var pendingValue: Value?

    init(
        remoteMediaClient: GCKRemoteMediaClient,
        get: @escaping (GCKMediaStatus?) -> Value,
        set: @escaping (GCKRemoteMediaClient, Value) -> GCKRequest
    ) {
        self.remoteMediaClient = remoteMediaClient
        self.get = get
        self.set = set
        self.value = get(remoteMediaClient.mediaStatus)
        super.init()
        remoteMediaClient.add(self)
    }

    func requestUpdate(to value: Value) {
        if currentRequest == nil {
            currentRequest = makeRequest(to: value)
        }
        else {
            pendingValue = value
        }
    }

    private func makeRequest(to value: Value) -> GCKRequest {
        self.value = value
        let request = set(remoteMediaClient, value)
        request.delegate = self
        return request
    }

    func remoteMediaClient(_ client: GCKRemoteMediaClient, didUpdate mediaStatus: GCKMediaStatus?) {
        if currentRequest == nil {
            value = get(mediaStatus)
        }
    }

    func requestDidComplete(_ request: GCKRequest) {
        if let pendingValue {
            currentRequest = makeRequest(to: pendingValue)
            self.pendingValue = nil
        }
    }
}
