//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import GoogleCast

final class RepeatModeSynchronizer: NSObject {
    private let remoteMediaClient: GCKRemoteMediaClient
    weak var delegate: ChangeDelegate?

    var repeatMode: CastRepeatMode {
        didSet {
            guard Self.repeatMode(for: remoteMediaClient.mediaStatus) != repeatMode else { return }
            remoteMediaClient.queueSetRepeatMode(repeatMode.rawMode())
        }
    }

    init(remoteMediaClient: GCKRemoteMediaClient) {
        self.remoteMediaClient = remoteMediaClient
        self.repeatMode = Self.repeatMode(for: remoteMediaClient.mediaStatus)
        super.init()
        remoteMediaClient.add(self)
    }

    private static func repeatMode(for mediaStatus: GCKMediaStatus?) -> CastRepeatMode {
        guard let mediaStatus, let repeatMode = CastRepeatMode(rawMode: mediaStatus.queueRepeatMode) else { return .off }
        return repeatMode
    }
}

extension RepeatModeSynchronizer: GCKRemoteMediaClientListener {
    func remoteMediaClient(_ client: GCKRemoteMediaClient, didUpdate mediaStatus: GCKMediaStatus?) {
        self.repeatMode = Self.repeatMode(for: mediaStatus)
        delegate?.didChange()
    }
}
