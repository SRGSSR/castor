//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Combine
import CoreMedia
import GoogleCast
import SwiftUI

/// A cast player.
public final class CastPlayer: NSObject, ObservableObject {
    private let remoteMediaClient: GCKRemoteMediaClient

    private let seek: CastSeek
    private let speed: CastPlaybackSpeed
    private let tracks: CastTracks

    @Published private var _activeMediaStatus: GCKMediaStatus?
    @Published private var _shouldPlay: Bool
    @Published private var _repeatMode: CastRepeatMode
    private var _playbackSpeed: Float = 1
    private var _activeTracks: [CastMediaTrack] = []

    public var shouldPlay: Bool {
        get {
            _shouldPlay
        }
        set {
            guard isActive, _shouldPlay != newValue else { return }
            _shouldPlay = newValue
            if newValue {
                remoteMediaClient.play()
            }
            else {
                remoteMediaClient.pause()
            }
        }
    }

    /// The mode with which the player repeats playback of items in its queue.
    public var repeatMode: CastRepeatMode {
        get {
            _repeatMode
        }
        set {
            guard isActive, _repeatMode != newValue else { return }
            _repeatMode = newValue
            remoteMediaClient.queueSetRepeatMode(newValue.rawMode())
        }
    }

    public var isActive: Bool {
        _activeMediaStatus != nil
    }

    /// The queue managing player items.
    public let queue: CastQueue

    var configuration: CastConfiguration

    init?(remoteMediaClient: GCKRemoteMediaClient?, configuration: CastConfiguration) {
        guard let remoteMediaClient else { return nil }

        self.remoteMediaClient = remoteMediaClient
        self.configuration = configuration

        let activeMediaStatus = Self.activeMediaStatus(from: remoteMediaClient.mediaStatus)
        _activeMediaStatus = activeMediaStatus
        _shouldPlay = Self.shouldPlay(for: activeMediaStatus)
        _repeatMode = Self.repeatMode(for: activeMediaStatus)

        queue = .init(remoteMediaClient: remoteMediaClient)
        seek = .init(remoteMediaClient: remoteMediaClient)
        speed = .init(remoteMediaClient: remoteMediaClient)
        tracks = .init(remoteMediaClient: remoteMediaClient)

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
        shouldPlay = true
    }

    /// Pauses.
    func pause() {
        shouldPlay = false
    }

    /// Toggles between play and pause.
    func togglePlayPause() {
        shouldPlay.toggle()
    }

    /// Stops.
    func stop() {
        remoteMediaClient.stop()
    }
}

public extension CastPlayer {
    /// The currently applicable playback speed.
    var effectivePlaybackSpeed: Float {
        _playbackSpeed.clamped(to: playbackSpeedRange)
    }

    /// The currently allowed playback speed range.
    var playbackSpeedRange: ClosedRange<Float> {
        _activeMediaStatus?.mediaInformation?.streamType == .buffered ? 0.5...2 : 1...1
    }

    /// A binding to read and write the current playback speed.
    var playbackSpeed: Binding<Float> {
        .init {
            self.effectivePlaybackSpeed
        } set: { newValue in
            self.setDesiredPlaybackSpeed(newValue)
        }
    }

    /// Sets the desired playback speed.
    ///
    /// - Parameter playbackSpeed: The playback speed. The default value is 1.
    ///
    /// This value might not be applied immediately or might not be applicable at all. You must check
    /// `effectivePlaybackSpeed` to obtain the actually applied speed.
    func setDesiredPlaybackSpeed(_ playbackSpeed: Float) {
        speed.request(for: playbackSpeed)
    }
}

public extension CastPlayer {
    /// The set of media characteristics for which a media selection is available.
    var mediaSelectionCharacteristics: Set<AVMediaCharacteristic> {
        Set(Self.tracks(from: _activeMediaStatus).compactMap(\.mediaCharacteristic))
    }

    private static func tracks(from mediaStatus: GCKMediaStatus?) -> [CastMediaTrack] {
        guard let rawTracks = mediaStatus?.mediaInformation?.mediaTracks else { return [] }
        return rawTracks.map { .init(rawTrack: $0) }
    }

    private static func activeTracks(from mediaStatus: GCKMediaStatus?) -> [CastMediaTrack] {
        guard let mediaStatus, let rawTracks = mediaStatus.mediaInformation?.mediaTracks, let activeTrackIDs = mediaStatus.activeTrackIDs else {
            return []
        }
        // swiftlint:disable:next legacy_objc_type
        return rawTracks.filter { activeTrackIDs.contains(NSNumber(value: $0.identifier)) }.map { .init(rawTrack: $0) }
    }

    /// Selects a media option for a characteristic.
    ///
    /// - Parameters:
    ///   - mediaOption: The option to select.
    ///   - characteristic: The characteristic.
    ///
    /// You can use `mediaSelectionCharacteristics` to retrieve available characteristics. This method does nothing when
    /// attempting to set an option that is not supported.
    func select(mediaOption: CastMediaSelectionOption, for characteristic: AVMediaCharacteristic) {
        var activeTracks = tracks.targetActiveTracks ?? Self.activeTracks(from: _activeMediaStatus)
        activeTracks.removeAll { $0.mediaCharacteristic == characteristic }
        switch mediaOption {
        case .off:
            break
        case let .on(track):
            activeTracks.append(track)
        }
        tracks.request(for: activeTracks)
    }

    /// The list of media options associated with a characteristic.
    ///
    /// - Parameter characteristic: The characteristic.
    /// - Returns: The list of options associated with the characteristic.
    ///
    /// Use `mediaSelectionCharacteristics` to retrieve available characteristics.
    func mediaSelectionOptions(for characteristic: AVMediaCharacteristic) -> [CastMediaSelectionOption] {
        let tracks = Self.tracks(from: _activeMediaStatus).filter { $0.mediaCharacteristic == characteristic }
        switch characteristic {
        case .audible where tracks.count > 1:
            return tracks.map { .on($0) }
        case .legible where !tracks.isEmpty:
            return [.off] + tracks.map { .on($0) }
        default:
            return []
        }
    }

    /// The currently selected media option for a characteristic.
    ///
    /// - Parameter characteristic: The characteristic.
    /// - Returns: The selected option.
    ///
    /// You can use `mediaSelectionCharacteristics` to retrieve available characteristics.
    func selectedMediaOption(for characteristic: AVMediaCharacteristic) -> CastMediaSelectionOption {
        let options = mediaSelectionOptions(for: characteristic)
        let currentOption = currentMediaOption(for: characteristic)
        return options.contains(currentOption) ? currentOption : .off
    }

    /// A binding to read and write the current media selection for a characteristic.
    ///
    /// - Parameter characteristic: The characteristic.
    /// - Returns: The binding.
    func mediaOption(for characteristic: AVMediaCharacteristic) -> Binding<CastMediaSelectionOption> {
        .init {
            self.selectedMediaOption(for: characteristic)
        } set: { newValue in
            self.select(mediaOption: newValue, for: characteristic)
        }
    }

    /// The current media option for a characteristic.
    ///
    /// - Parameter characteristic: The characteristic.
    /// - Returns: The current option.
    ///
    /// Unlike `selectedMediaOption(for:)` this method provides the currently applied option. This method can
    /// be useful if you need to access the actual selection made by `select(mediaOption:for:)` for `.automatic`
    /// and `.off` options (forced options might be returned where applicable).
    func currentMediaOption(for characteristic: AVMediaCharacteristic) -> CastMediaSelectionOption {
        switch characteristic {
        case .audible, .legible:
            guard let track = _activeTracks.first(where: { $0.mediaCharacteristic == characteristic }) else { return .off }
            return .on(track)
        default:
            return .off
        }
    }
}

public extension CastPlayer {
    /// Player state.
    var state: GCKMediaPlayerState {
        _activeMediaStatus?.playerState ?? .unknown
    }

    /// Media information.
    var mediaInformation: GCKMediaInformation? {
        _activeMediaStatus?.mediaInformation
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
        seek.request(for: time)
    }
}

extension CastPlayer {
    var backwardSkipTime: CMTime {
        CMTime(seconds: -configuration.backwardSkipInterval, preferredTimescale: 1)
    }

    var forwardSkipTime: CMTime {
        CMTime(seconds: configuration.forwardSkipInterval, preferredTimescale: 1)
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
        let currentTime = seek.targetTime ?? time()
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
    func canSkip(_ skip: CastSkip) -> Bool {
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
        let currentTime = seek.targetTime ?? time()
        seek(to: CMTimeClampToRange(currentTime + backwardSkipTime, range: seekableTimeRange()))
    }

    /// Skips forward.
    func skipForward() {
        let currentTime = seek.targetTime ?? time()
        seek(to: CMTimeClampToRange(currentTime + forwardSkipTime, range: seekableTimeRange()))
    }

    /// Skips in a given direction.
    ///
    /// - Parameter skip: The skip direction.
    func skip(_ skip: CastSkip) {
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
            seek.$targetTime,
            objectWillChange,
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
        _activeMediaStatus = Self.activeMediaStatus(from: mediaStatus)

        _shouldPlay = Self.shouldPlay(for: _activeMediaStatus)
        _repeatMode = Self.repeatMode(for: _activeMediaStatus)
    }

    private static func activeMediaStatus(from mediaStatus: GCKMediaStatus?) -> GCKMediaStatus? {
        guard let mediaStatus, mediaStatus.mediaSessionID != 0 else { return nil }
        return mediaStatus
    }

    private static func shouldPlay(for mediaStatus: GCKMediaStatus?) -> Bool {
        guard let mediaStatus, mediaStatus.playerState == .playing else { return false }
        return true
    }

    private static func repeatMode(for mediaStatus: GCKMediaStatus?) -> CastRepeatMode {
        guard let mediaStatus, let repeatMode = CastRepeatMode(rawMode: mediaStatus.queueRepeatMode) else { return .off }
        return repeatMode
    }
}

private extension CastPlayer {
    static func isValidTimeInterval(_ timeInterval: TimeInterval) -> Bool {
        GCKIsValidTimeInterval(timeInterval) && timeInterval != .infinity
    }
}
