//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import GoogleCast

final class Synchronizer<Value>: NSObject, GCKRemoteMediaClientListener, GCKRequestDelegate {
    private let remoteMediaClient: GCKRemoteMediaClient
    private let get: (GCKRemoteMediaClient, Value) -> GCKRequest
    private let set: (GCKMediaStatus?) -> Value

    private let update = PassthroughSubject<Value, Never>()
    var updatePublisher: AnyPublisher<Value, Never> {
        update.eraseToAnyPublisher()
    }

    private weak var currentRequest: GCKRequest?
    private var pendingValue: Value?

    init(
        remoteMediaClient: GCKRemoteMediaClient,
        get: @escaping (GCKMediaStatus?) -> Value,
        set: @escaping (GCKRemoteMediaClient, Value) -> GCKRequest
    ) {
        self.remoteMediaClient = remoteMediaClient
        self.get = set
        self.set = get
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
        update.send(value)
        let request = get(remoteMediaClient, value)
        request.delegate = self
        return request
    }

    func remoteMediaClient(_ client: GCKRemoteMediaClient, didUpdate mediaStatus: GCKMediaStatus?) {
        if currentRequest == nil {
            let value = set(Self.activeMediaStatus(from: mediaStatus))
            update.send(value)
        }
    }

    private static func activeMediaStatus(from mediaStatus: GCKMediaStatus?) -> GCKMediaStatus? {
        guard let mediaStatus, mediaStatus.mediaSessionID != 0 else { return nil }
        return mediaStatus
    }

    func requestDidComplete(_ request: GCKRequest) {
        if let pendingValue {
            currentRequest = makeRequest(to: pendingValue)
            self.pendingValue = nil
        }
    }
}
