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
    private let update: (Float) -> Void

    private weak var currentRequest: GCKRequest?
    private var pendingPlaybackSpeed: Float?

    private var inhibitedCount = 0

    init(remoteMediaClient: GCKRemoteMediaClient, update: @escaping (Float) -> Void) {
        self.remoteMediaClient = remoteMediaClient
        self.update = update
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
        update(playbackSpeed)
        print("--> (optimistic) update to \(playbackSpeed)")
        let request = remoteMediaClient.setPlaybackRate(playbackSpeed)
        request.delegate = self
        inhibitedCount += 1
        return request
    }
}

extension PlaybackSpeedSynchronizer: GCKRemoteMediaClientListener {
    func remoteMediaClient(_ client: GCKRemoteMediaClient, didUpdate mediaStatus: GCKMediaStatus?) {
        print("--> media status update")
        inhibitedCount = max(inhibitedCount - 1, 0)
        if inhibitedCount == 0 {
            let playbackSpeed = Self.playbackSpeed(for: Self.activeMediaStatus(from: mediaStatus))
            update(playbackSpeed)
            print("--> (received) update to \(playbackSpeed)")
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
        print("--> request did complete")
        if let pendingPlaybackSpeed {
            currentRequest = makeRequest(to: pendingPlaybackSpeed)
            self.pendingPlaybackSpeed = nil
        }
    }
}
