//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import GoogleCast

final class CastRepeat: NSObject {
    private let remoteMediaClient: GCKRemoteMediaClient
    weak var delegate: ChangeDelegate?

    var value: CastRepeatMode {
        didSet {
            guard Self.value(for: remoteMediaClient.mediaStatus) != value else { return }
            remoteMediaClient.queueSetRepeatMode(value.rawMode())
        }
    }

    init(remoteMediaClient: GCKRemoteMediaClient) {
        self.remoteMediaClient = remoteMediaClient
        self.value = Self.value(for: remoteMediaClient.mediaStatus)
        super.init()
        remoteMediaClient.add(self)
    }

    private static func value(for mediaStatus: GCKMediaStatus?) -> CastRepeatMode {
        guard let mediaStatus, let repeatMode = CastRepeatMode(rawMode: mediaStatus.queueRepeatMode) else { return .off }
        return repeatMode
    }
}

extension CastRepeat: GCKRemoteMediaClientListener {
    func remoteMediaClient(_ client: GCKRemoteMediaClient, didUpdate mediaStatus: GCKMediaStatus?) {
        self.value = Self.value(for: mediaStatus)
        delegate?.didChange()
    }
}
