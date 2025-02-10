//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import CoreMedia
import GoogleCast

/// A cast player.
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

    /// Creates the player.
    override public init() {
        currentCastSession = context.sessionManager.currentCastSession
        mediaStatus = currentCastSession?.remoteMediaClient?.mediaStatus

        super.init()

        context.sessionManager.add(self)
        remoteMediaClient?.add(self)
    }
}

public extension CastPlayer {
    /// Plays.
    func play() {
        remoteMediaClient?.play()
    }

    /// Pauses.
    func pause() {
        remoteMediaClient?.pause()
    }

    /// Toggles between play and pause.
    func togglePlayPause() {
        if state == .playing {
            pause()
        }
        else {
            play()
        }
    }

    /// Stops.
    func stop() {
        remoteMediaClient?.stop()
    }
}

public extension CastPlayer {
    /// Player state.
    var state: GCKMediaPlayerState {
        mediaStatus?.playerState ?? .unknown
    }

    /// Media information.
    var mediaInformation: GCKMediaInformation? {
        mediaStatus?.mediaInformation
    }

    /// Device.
    var device: GCKDevice? {
        currentCastSession?.device
    }

    /// Returns if the player is busy.
    var isBusy: Bool {
        state == .buffering || state == .loading
    }

    private static func isValidTimeInterval(_ timeInterval: TimeInterval) -> Bool {
        GCKIsValidTimeInterval(timeInterval) && timeInterval != .infinity
    }

    /// Time.
    func time() -> CMTime {
        guard let position = remoteMediaClient?.approximateStreamPosition() else { return .invalid }
        return .init(seconds: position, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
    }

    /// Seekable time range.
    func seekableTimeRange() -> CMTimeRange {
        guard let remoteMediaClient else { return .invalid }
        let start = remoteMediaClient.approximateLiveSeekableRangeStart()
        let end = remoteMediaClient.approximateLiveSeekableRangeEnd()
        if Self.isValidTimeInterval(start), Self.isValidTimeInterval(end), start != end {
            return .init(
                start: .init(seconds: start, preferredTimescale: CMTimeScale(NSEC_PER_SEC)),
                end: .init(seconds: end, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
            )
        }
        else if let streamDuration = mediaInformation?.streamDuration, Self.isValidTimeInterval(streamDuration), streamDuration != 0 {
            return .init(start: .zero, end: .init(seconds: streamDuration, preferredTimescale: CMTimeScale(NSEC_PER_SEC)))
        }
        else {
            return .invalid
        }
    }
}

extension CastPlayer: GCKSessionManagerListener {
    public func sessionManager(_ sessionManager: GCKSessionManager, didStart session: GCKCastSession) {
        currentCastSession = session
    }

    public func sessionManager(_ sessionManager: GCKSessionManager, didResumeCastSession session: GCKCastSession) {
        currentCastSession = session
    }

    public func sessionManager(_ sessionManager: GCKSessionManager, didEnd session: GCKCastSession, withError error: (any Error)?) {
        currentCastSession = nil
    }

    public func sessionManager(_ sessionManager: GCKSessionManager, didFailToStart session: GCKCastSession, withError error: any Error) {
        currentCastSession = nil
    }
}

extension CastPlayer: GCKRemoteMediaClientListener {
    public func remoteMediaClient(_ client: GCKRemoteMediaClient, didUpdate mediaStatus: GCKMediaStatus?) {
        self.mediaStatus = mediaStatus
    }
}
