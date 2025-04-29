//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import CoreMedia
import GoogleCast
import SwiftUI

/// A cast player.
public final class CastPlayer: NSObject, ObservableObject {
    private let remoteMediaClient: GCKRemoteMediaClient
    private var targetSeekTimePublisher = CurrentValueSubject<CMTime?, Never>(nil)

    @Published private var mediaStatus: GCKMediaStatus?

    /// The queue managing player items.
    public let queue: CastQueue

    init?(remoteMediaClient: GCKRemoteMediaClient?) {
        guard let remoteMediaClient else { return nil }

        self.remoteMediaClient = remoteMediaClient
        mediaStatus = remoteMediaClient.mediaStatus
        queue = .init(remoteMediaClient: remoteMediaClient)

        super.init()

        remoteMediaClient.add(self)
    }

    deinit {
        queue.release()
    }
}

public extension CastPlayer {
    /// Plays.
    func play() {
        remoteMediaClient.play()
    }

    /// Pauses.
    func pause() {
        remoteMediaClient.pause()
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
        remoteMediaClient.stop()
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

    /// Returns if the player is busy.
    var isBusy: Bool {
        state == .buffering || state == .loading
    }

    /// Time.
    func time() -> CMTime {
        .init(seconds: remoteMediaClient.approximateStreamPosition(), preferredTimescale: CMTimeScale(NSEC_PER_SEC))
    }

    /// Seekable time range.
    func seekableTimeRange() -> CMTimeRange {
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

public extension CastPlayer {
    /// Performs a seek to a given time.
    ///
    /// - Parameter time: The time to reach.
    func seek(to time: CMTime) {
        updateSeekTargetTime(to: time)
        let options = GCKMediaSeekOptions()
        options.interval = time.seconds
        let request = remoteMediaClient.seek(with: options)
        request.delegate = self
    }
}

extension CastPlayer {
    func updateSeekTargetTime(to time: CMTime?) {
        targetSeekTimePublisher.send(time)
    }

    func smoothTimePublisher(interval: CMTime) -> AnyPublisher<CMTime, Never> {
        Publishers.CombineLatest(
            targetSeekTimePublisher,
            Timer.publish(every: interval.seconds, on: .main, in: .common)
                .autoconnect(),
        )
        .compactMap { [weak self] targetSeekTime, _ in
            guard let self else { return nil }
            return targetSeekTime ?? time()
        }
        .eraseToAnyPublisher()
    }

    func timePropertiesPublisher(interval: CMTime) -> AnyPublisher<TimeProperties, Never> {
        smoothTimePublisher(interval: interval)
            .compactMap { [weak self] time in
                guard let self else { return nil }
                return .init(time: time, timeRange: seekableTimeRange())
            }
            .eraseToAnyPublisher()
    }
}

extension CastPlayer: GCKRemoteMediaClientListener {
    // swiftlint:disable:next missing_docs
    public func remoteMediaClient(_ client: GCKRemoteMediaClient, didUpdate mediaStatus: GCKMediaStatus?) {
        self.mediaStatus = mediaStatus
    }
}

extension CastPlayer: GCKRequestDelegate {
    // swiftlint:disable:next missing_docs
    public func requestDidComplete(_ request: GCKRequest) {
        updateSeekTargetTime(to: nil)
    }

    // swiftlint:disable:next missing_docs
    public func request(_ request: GCKRequest, didAbortWith abortReason: GCKRequestAbortReason) {
        updateSeekTargetTime(to: nil)
    }

    // swiftlint:disable:next missing_docs
    public func request(_ request: GCKRequest, didFailWithError error: GCKError) {
        updateSeekTargetTime(to: nil)
    }
}

private extension CastPlayer {
    static func isValidTimeInterval(_ timeInterval: TimeInterval) -> Bool {
        GCKIsValidTimeInterval(timeInterval) && timeInterval != .infinity
    }
}
