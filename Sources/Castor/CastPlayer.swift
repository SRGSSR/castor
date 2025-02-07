//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import GoogleCast

public final class CastPlayer: NSObject, ObservableObject {
    private let context = GCKCastContext.sharedInstance()

    @Published private var mediaStatus: GCKMediaStatus?

    private var remoteMediaClient: GCKRemoteMediaClient? {
        didSet {
            oldValue?.remove(self)
            remoteMediaClient?.add(self)
            mediaStatus = remoteMediaClient?.mediaStatus
        }
    }

    public override init() {
        remoteMediaClient = context.sessionManager.currentCastSession?.remoteMediaClient
        mediaStatus = remoteMediaClient?.mediaStatus

        super.init()

        context.sessionManager.add(self)
        remoteMediaClient?.add(self)
    }
}

public extension CastPlayer {
    func play() {
        remoteMediaClient?.play()
    }

    func pause() {
        remoteMediaClient?.pause()
    }

    func togglePlayPause() {
        state == .playing ? pause() : play()
    }

    func stop() {
        remoteMediaClient?.stop()
    }
}

public extension CastPlayer {
    var state: GCKMediaPlayerState {
        mediaStatus?.playerState ?? .unknown
    }

    var mediaInformation: GCKMediaInformation? {
        mediaStatus?.mediaInformation
    }
}

extension CastPlayer: GCKSessionManagerListener {
    public func sessionManager(_ sessionManager: GCKSessionManager, didStart session: GCKCastSession) {
        remoteMediaClient = session.remoteMediaClient
    }

    public func sessionManager(_ sessionManager: GCKSessionManager, didEnd session: GCKCastSession, withError error: (any Error)?) {
        remoteMediaClient = nil
    }
}

extension CastPlayer: GCKRemoteMediaClientListener {
    public func remoteMediaClient(_ client: GCKRemoteMediaClient, didUpdate mediaStatus: GCKMediaStatus?) {
        self.mediaStatus = mediaStatus
    }
}
