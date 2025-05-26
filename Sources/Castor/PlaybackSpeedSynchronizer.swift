//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import GoogleCast

// TODO: Probably possible to make generic with request/parsing result. Then use also for other properties like
//       shouldPlay or repeat mode

final class PlaybackSpeedSynchronizer: NSObject {
    private let remoteMediaClient: GCKRemoteMediaClient

    var update: ((Float) -> Void)?

    private weak var currentRequest: GCKRequest?
    private var pendingPlaybackSpeed: Float?

    init(remoteMediaClient: GCKRemoteMediaClient) {
        self.remoteMediaClient = remoteMediaClient
        super.init()
        remoteMediaClient.add(self)
    }

    func requestUpdate(to playbackSpeed: Float) {
        if currentRequest == nil {
            currentRequest = makeRequest(to: playbackSpeed)
        }
        else {
            pendingPlaybackSpeed = playbackSpeed
        }
    }

    private func makeRequest(to playbackSpeed: Float) -> GCKRequest {
        update?(playbackSpeed)
        let request = remoteMediaClient.setPlaybackRate(playbackSpeed)
        request.delegate = self
        return request
    }
}

extension PlaybackSpeedSynchronizer: GCKRemoteMediaClientListener {
    func remoteMediaClient(_ client: GCKRemoteMediaClient, didUpdate mediaStatus: GCKMediaStatus?) {
        if currentRequest == nil {
            let playbackSpeed = Self.playbackSpeed(for: Self.activeMediaStatus(from: mediaStatus))
            update?(playbackSpeed)
        }
    }

    private static func activeMediaStatus(from mediaStatus: GCKMediaStatus?) -> GCKMediaStatus? {
        guard let mediaStatus, mediaStatus.mediaSessionID != 0 else { return nil }
        return mediaStatus
    }

    private static func playbackSpeed(for mediaStatus: GCKMediaStatus?) -> Float {
        mediaStatus?.playbackRate ?? 1
    }
}

extension PlaybackSpeedSynchronizer: GCKRequestDelegate {
    func requestDidComplete(_ request: GCKRequest) {
        if let pendingPlaybackSpeed {
            currentRequest = makeRequest(to: pendingPlaybackSpeed)
            self.pendingPlaybackSpeed = nil
        }
    }
}
