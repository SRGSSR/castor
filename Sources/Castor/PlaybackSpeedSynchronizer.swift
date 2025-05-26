//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import GoogleCast

final class Synchronizer<Value>: NSObject, GCKRemoteMediaClientListener, GCKRequestDelegate {
    private let remoteMediaClient: GCKRemoteMediaClient
    private let builder: (GCKRemoteMediaClient, Value) -> GCKRequest
    private let parser: (GCKMediaStatus?) -> Value

    var update: ((Value) -> Void)?

    private weak var currentRequest: GCKRequest?
    private var pendingPlaybackSpeed: Value?

    init(
        remoteMediaClient: GCKRemoteMediaClient,
        builder: @escaping (GCKRemoteMediaClient, Value) -> GCKRequest,
        parser: @escaping (GCKMediaStatus?) -> Value
    ) {
        self.remoteMediaClient = remoteMediaClient
        self.builder = builder
        self.parser = parser
        super.init()
        remoteMediaClient.add(self)
    }

    func requestUpdate(to playbackSpeed: Value) {
        if currentRequest == nil {
            currentRequest = makeRequest(to: playbackSpeed)
        }
        else {
            pendingPlaybackSpeed = playbackSpeed
        }
    }

    private func makeRequest(to value: Value) -> GCKRequest {
        update?(value)
        let request = builder(remoteMediaClient, value)
        request.delegate = self
        return request
    }

    func remoteMediaClient(_ client: GCKRemoteMediaClient, didUpdate mediaStatus: GCKMediaStatus?) {
        if currentRequest == nil {
            let playbackSpeed = parser(Self.activeMediaStatus(from: mediaStatus))
            update?(playbackSpeed)
        }
    }

    private static func activeMediaStatus(from mediaStatus: GCKMediaStatus?) -> GCKMediaStatus? {
        guard let mediaStatus, mediaStatus.mediaSessionID != 0 else { return nil }
        return mediaStatus
    }

    func requestDidComplete(_ request: GCKRequest) {
        if let pendingPlaybackSpeed {
            currentRequest = makeRequest(to: pendingPlaybackSpeed)
            self.pendingPlaybackSpeed = nil
        }
    }
}
