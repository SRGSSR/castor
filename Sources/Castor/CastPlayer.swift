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
    private var seekTargetTime: CMTime? {
        get {
            targetSeekTimePublisher.value
        }
        set {
            targetSeekTimePublisher.send(newValue)
        }
    }

    /// Performs a seek to a given time.
    ///
    /// - Parameter time: The time to reach.
    func seek(to time: CMTime) {
        seekTargetTime = time
        let options = GCKMediaSeekOptions()
        options.interval = time.seconds
        let request = remoteMediaClient.seek(with: options)
        request.delegate = self
    }
}

extension CastPlayer {
    var backwardSkipTime: CMTime {
        CMTime(seconds: -10, preferredTimescale: 1)
    }

    var forwardSkipTime: CMTime {
        CMTime(seconds: 10, preferredTimescale: 1)
    }
}

public extension CastPlayer {
    /// Checks whether seeking to a specific time is possible.
    ///
    /// - Parameter time: The time to seek to.
    /// - Returns: `true` if possible.
    func canSeek(to time: CMTime) -> Bool {
        let seekableTimeRange = seekableTimeRange()
        guard seekableTimeRange.isValidAndNotEmpty else { return false }
        return seekableTimeRange.start <= time && time <= seekableTimeRange.end
    }

    /// Checks whether skipping backward is possible.
    ///
    /// - Returns: `true` if possible.
    func canSkipBackward() -> Bool {
        seekableTimeRange().isValidAndNotEmpty
    }

    /// Checks whether skipping forward is possible.
    ///
    /// - Returns: `true` if possible.
    func canSkipForward() -> Bool {
        let seekableTimeRange = seekableTimeRange()
        guard seekableTimeRange.isValidAndNotEmpty else { return false }
        let currentTime = seekTargetTime ?? time()
        return canSeek(to: currentTime + forwardSkipTime)
    }

    /// Returns whether the current player item player can be returned to its default position.
    ///
    /// - Returns: `true` if skipping to the default position is possible.
    ///
    /// For a livestream supporting DVR this method can be used to check whether the stream is played at the live
    /// edge or not.
    func canSkipToDefault() -> Bool {
        guard let mediaInformation else { return false }
        switch mediaInformation.streamType {
        case .live where seekableTimeRange().isValidAndNotEmpty:
            return time() < seekableTimeRange().end - forwardSkipTime
        case .live:
            return false
        case .buffered:
            return true
        default:
            return false
        }
    }

    /// Checks whether skipping in some direction is possible.
    ///
    /// - Returns: `true` if possible.
    func canSkip(_ skip: Skip) -> Bool {
        switch skip {
        case .backward:
            return canSkipBackward()
        case .forward:
            return canSkipForward()
        }
    }
}

public extension CastPlayer {
    /// Skips backward.
    func skipBackward() {
        let currentTime = seekTargetTime ?? time()
        seek(to: CMTimeClampToRange(currentTime - .init(value: 10, timescale: 1), range: seekableTimeRange()))
    }

    /// Skips forward.
    func skipForward() {
        let currentTime = seekTargetTime ?? time()
        seek(to: CMTimeClampToRange(currentTime + .init(value: 10, timescale: 1), range: seekableTimeRange()))
    }

    /// Skips in a given direction.
    ///
    /// - Parameter skip: The skip direction.
    func skip(_ skip: Skip) {
        switch skip {
        case .backward:
            skipBackward()
        case .forward:
            skipForward()
        }
    }

    /// Returns the current item to its default position.
    ///
    /// For a livestream supporting DVR the default position corresponds to the live edge.
    func skipToDefault() {
        guard let mediaInformation else { return }
        switch mediaInformation.streamType {
        case .live:
            seek(to: seekableTimeRange().end)
        case .buffered:
            seek(to: seekableTimeRange().start)
        default:
            return
        }
    }
}

extension CastPlayer {
    private func pulsePublisher(interval: CMTime) -> AnyPublisher<Void, Never> {
        Timer.publish(every: interval.seconds, on: .main, in: .common)
            .autoconnect()
            .map { _ in }
            .prepend(())
            .eraseToAnyPublisher()
    }

    private func smoothTimePublisher(interval: CMTime) -> AnyPublisher<CMTime, Never> {
        Publishers.CombineLatest3(
            targetSeekTimePublisher,
            $mediaStatus,
            pulsePublisher(interval: interval)
        )
        .weakCapture(self)
        .map { ($0.0, $1) }
        .map { targetSeekTime, player in
            targetSeekTime ?? player.time()
        }
        .eraseToAnyPublisher()
    }

    func timePropertiesPublisher(interval: CMTime) -> AnyPublisher<TimeProperties, Never> {
        smoothTimePublisher(interval: interval)
            .weakCapture(self)
            .map { time, player in
                TimeProperties(time: time, timeRange: player.seekableTimeRange())
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
        seekTargetTime = nil
    }

    // swiftlint:disable:next missing_docs
    public func request(_ request: GCKRequest, didAbortWith abortReason: GCKRequestAbortReason) {
        seekTargetTime = nil
    }

    // swiftlint:disable:next missing_docs
    public func request(_ request: GCKRequest, didFailWithError error: GCKError) {
        seekTargetTime = nil
    }
}

private extension CastPlayer {
    static func isValidTimeInterval(_ timeInterval: TimeInterval) -> Bool {
        GCKIsValidTimeInterval(timeInterval) && timeInterval != .infinity
    }
}
