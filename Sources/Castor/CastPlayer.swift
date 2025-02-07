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

    private var currentCastSession: GCKCastSession? {
        didSet {
            oldValue?.remoteMediaClient?.remove(self)
            currentCastSession?.remoteMediaClient?.add(self)
            mediaStatus = currentCastSession?.remoteMediaClient?.mediaStatus
        }
    }

    private var remoteMediaClient: GCKRemoteMediaClient? {
        currentCastSession?.remoteMediaClient
    }

    public override init() {
        currentCastSession = context.sessionManager.currentCastSession
        mediaStatus = currentCastSession?.remoteMediaClient?.mediaStatus

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

    var device: GCKDevice? {
        currentCastSession?.device
    }
}

extension CastPlayer: GCKSessionManagerListener {
    public func sessionManager(_ sessionManager: GCKSessionManager, didStart session: GCKCastSession) {
        currentCastSession = session
    }

    public func sessionManager(_ sessionManager: GCKSessionManager, didEnd session: GCKCastSession, withError error: (any Error)?) {
        currentCastSession = nil
    }
}

extension CastPlayer: GCKRemoteMediaClientListener {
    public func remoteMediaClient(_ client: GCKRemoteMediaClient, didUpdate mediaStatus: GCKMediaStatus?) {
        self.mediaStatus = mediaStatus
    }
}
