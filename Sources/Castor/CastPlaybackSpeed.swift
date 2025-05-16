//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import GoogleCast

final class CastPlaybackSpeed: NSObject {
    private let remoteMediaClient: GCKRemoteMediaClient
    weak var delegate: ChangeDelegate?

    private weak var request: GCKRequest?
    private var requestValue: Float?
    private var pendingRequestValue: Float?

    var value: Float {
        didSet {
            guard remoteMediaClient.mediaStatus?.playbackRate != value else { return }
            if request == nil {
                request = makeRequest(to: value)
            }
            pendingRequestValue = value
        }
    }

    var range: ClosedRange<Float> {
        Self.range(for: remoteMediaClient.mediaStatus)
    }

    init(remoteMediaClient: GCKRemoteMediaClient) {
        self.remoteMediaClient = remoteMediaClient
        self.value = Self.value(for: remoteMediaClient.mediaStatus)
        super.init()
        remoteMediaClient.add(self)
    }

    private static func value(for mediaStatus: GCKMediaStatus?) -> Float {
        mediaStatus?.playbackRate ?? 1
    }

    private static func range(for mediaStatus: GCKMediaStatus?) -> ClosedRange<Float> {
        guard let mediaStatus, let mediaInformation = mediaStatus.mediaInformation, mediaInformation.streamType == .buffered else {
            return 1...1
        }
        return 0.5...2
    }

    private func makeRequest(to value: Float) -> GCKRequest {
        let request = remoteMediaClient.setPlaybackRate(value)
        request.delegate = self
        requestValue = value
        return request
    }
}

extension CastPlaybackSpeed: GCKRemoteMediaClientListener {
    func remoteMediaClient(_ client: GCKRemoteMediaClient, didUpdate mediaStatus: GCKMediaStatus?) {
        if let mediaStatus, let pendingRequestValue {
            guard abs(mediaStatus.playbackRate - pendingRequestValue) < 0.01 else { return }
            self.pendingRequestValue = nil
        }
        value = Self.value(for: mediaStatus)
        delegate?.didChange()
    }
}

extension CastPlaybackSpeed: GCKRequestDelegate {
    // swiftlint:disable:next missing_docs
    public func requestDidComplete(_ request: GCKRequest) {
        guard let pendingRequestValue, pendingRequestValue != requestValue else { return }
        self.request = makeRequest(to: pendingRequestValue)
    }
}
