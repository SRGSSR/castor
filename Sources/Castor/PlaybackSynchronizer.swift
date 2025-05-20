//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import GoogleCast

final class PlaybackSynchronizer: NSObject {
    private let remoteMediaClient: GCKRemoteMediaClient
    weak var delegate: ChangeDelegate?

    var shouldPlay: Bool {
        didSet {
            guard Self.shouldPlay(for: remoteMediaClient.mediaStatus) != shouldPlay else { return }
            if shouldPlay {
                remoteMediaClient.play()
            }
            else {
                remoteMediaClient.pause()
            }
        }
    }

    init(remoteMediaClient: GCKRemoteMediaClient) {
        self.remoteMediaClient = remoteMediaClient
        self.shouldPlay = Self.shouldPlay(for: remoteMediaClient.mediaStatus)
        super.init()
        remoteMediaClient.add(self)
    }

    private static func shouldPlay(for mediaStatus: GCKMediaStatus?) -> Bool {
        guard let mediaStatus else { return false }
        return mediaStatus.playerState == .playing
    }
}

extension PlaybackSynchronizer: GCKRemoteMediaClientListener {
    func remoteMediaClient(_ client: GCKRemoteMediaClient, didUpdate mediaStatus: GCKMediaStatus?) {
        self.shouldPlay = Self.shouldPlay(for: mediaStatus)
        delegate?.didChange()
    }
}
