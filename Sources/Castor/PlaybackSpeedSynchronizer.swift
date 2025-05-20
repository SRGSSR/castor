//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import GoogleCast

final class PlaybackSpeedSynchronizer: NSObject {
    private let remoteMediaClient: GCKRemoteMediaClient
    weak var delegate: ChangeDelegate?

    private weak var request: GCKRequest?
    private var requestSpeed: Float?
    private var pendingRequestSpeed: Float?

    var speed: Float {
        didSet {
            guard remoteMediaClient.mediaStatus?.playbackRate != speed else { return }
            if request == nil {
                request = makeRequest(to: speed)
            }
            pendingRequestSpeed = speed
        }
    }

    var range: ClosedRange<Float> {
        guard let mediaStatus = remoteMediaClient.mediaStatus, let range = Self.range(for: mediaStatus) else { return 1...1 }
        return range
    }

    init(remoteMediaClient: GCKRemoteMediaClient) {
        self.remoteMediaClient = remoteMediaClient
        self.speed = Self.speed(for: remoteMediaClient.mediaStatus)
        super.init()
        remoteMediaClient.add(self)
    }

    private static func speed(for mediaStatus: GCKMediaStatus?) -> Float {
        guard let mediaStatus else { return 1 }
        if let range = Self.range(for: mediaStatus) {
            return mediaStatus.playbackRate.clamped(to: range)
        }
        else {
            return mediaStatus.playbackRate
        }
    }

    private static func range(for mediaStatus: GCKMediaStatus) -> ClosedRange<Float>? {
        switch mediaStatus.mediaInformation?.streamType {
        case .buffered:
            return 0.5...2
        case .live:
            return 1...1
        default:
            return nil
        }
    }

    private func makeRequest(to speed: Float) -> GCKRequest {
        let request = remoteMediaClient.setPlaybackRate(speed)
        request.delegate = self
        requestSpeed = speed
        return request
    }
}

extension PlaybackSpeedSynchronizer: GCKRemoteMediaClientListener {
    func remoteMediaClient(_ client: GCKRemoteMediaClient, didUpdate mediaStatus: GCKMediaStatus?) {
        if let mediaStatus, let pendingRequestSpeed {
            guard abs(mediaStatus.playbackRate - pendingRequestSpeed) < 0.01 else { return }
            self.pendingRequestSpeed = nil
        }
        speed = Self.speed(for: mediaStatus)
        delegate?.didChange()
    }
}

extension PlaybackSpeedSynchronizer: GCKRequestDelegate {
    // swiftlint:disable:next missing_docs
    public func requestDidComplete(_ request: GCKRequest) {
        guard let pendingRequestSpeed, pendingRequestSpeed != requestSpeed else { return }
        self.request = makeRequest(to: pendingRequestSpeed)
    }
}
