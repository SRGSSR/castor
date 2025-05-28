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

protocol ReceiverService {
    associatedtype Status

    var isConnected: Bool { get }
    var status: Status? { get }
}

extension GCKRemoteMediaClient: ReceiverService {
    typealias Status = GCKMediaStatus

    var isConnected: Bool {
        mediaStatus?.mediaSessionID != 0
    }

    var status: GCKMediaStatus? {
        mediaStatus
    }
}

struct DeviceSettings {
    let volume: Float
    let isMuted: Bool
}

extension GCKSessionManager: ReceiverService {
    typealias Status = DeviceSettings

    var isConnected: Bool {
        currentCastSession != nil
    }

    var status: DeviceSettings? {
        guard let currentCastSession else { return nil }
        return .init(volume: currentCastSession.currentDeviceVolume, isMuted: currentCastSession.currentDeviceMuted)
    }
}

protocol SynchronizerRecipe: AnyObject {
    associatedtype Service: ReceiverService
    associatedtype Value: Equatable

    init(service: Service, update: @escaping (Service.Status?) -> Void)

    func value(from status: Service.Status) -> Value
    func makeRequest(for value: Value, using service: Service) -> GCKRequest
}

extension SynchronizerRecipe {
    func value(from status: Service.Status?, defaultValue: Value) -> Value {
        guard let status else { return defaultValue }
        return value(from: status)
    }
}

final class VolumeRecipe: NSObject, SynchronizerRecipe, GCKSessionManagerListener {
    let update: (DeviceSettings?) -> Void

    init(service: GCKSessionManager, update: @escaping (DeviceSettings?) -> Void) {
        self.update = update
        super.init()
        service.add(self)
    }

    func value(from status: DeviceSettings) -> Float {
        status.volume
    }

    func makeRequest(for value: Float, using service: GCKSessionManager) -> GCKRequest {
        // TODO: Deal with potential unavailability, possibly with ReceiverService / a getter replacing isConnected
        //       that returns the requester to use
        service.currentCastSession?.setDeviceVolume(value) ?? .init()
    }

    func sessionManager(
        _ sessionManager: GCKSessionManager,
        castSession session: GCKCastSession,
        didReceiveDeviceVolume volume: Float,
        muted: Bool
    ) {
        update(.init(volume: volume, isMuted: muted))
    }
}

final class MutedRecipe: NSObject, SynchronizerRecipe, GCKSessionManagerListener {
    let update: (DeviceSettings?) -> Void

    init(service: GCKSessionManager, update: @escaping (DeviceSettings?) -> Void) {
        self.update = update
        super.init()
        service.add(self)
    }

    func value(from status: DeviceSettings) -> Bool {
        status.isMuted
    }

    func makeRequest(for value: Bool, using service: GCKSessionManager) -> GCKRequest {
        // TODO: Deal with potential unavailability, possibly with ReceiverService / a getter replacing isConnected
        //       that returns the requester to use
        service.currentCastSession?.setDeviceMuted(value) ?? .init()
    }

    func sessionManager(
        _ sessionManager: GCKSessionManager,
        castSession session: GCKCastSession,
        didReceiveDeviceVolume volume: Float,
        muted: Bool
    ) {
        update(.init(volume: volume, isMuted: muted))
    }
}

final class ShouldPlayRecipe: NSObject, SynchronizerRecipe, GCKRemoteMediaClientListener {
    let update: (GCKMediaStatus?) -> Void

    init(service: GCKRemoteMediaClient, update: @escaping (GCKMediaStatus?) -> Void) {
        self.update = update
        super.init()
        service.add(self)
    }

    func value(from status: GCKMediaStatus) -> Bool {
        status.playerState == .playing
    }

    func makeRequest(for value: Bool, using remoteMediaClient: GCKRemoteMediaClient) -> GCKRequest {
        if value {
            return remoteMediaClient.play()
        }
        else {
            return remoteMediaClient.pause()
        }
    }

    func remoteMediaClient(_ client: GCKRemoteMediaClient, didUpdate mediaStatus: GCKMediaStatus?) {
        update(mediaStatus)
    }
}

final class PlaybackSpeedRecipe: NSObject, SynchronizerRecipe, GCKRemoteMediaClientListener {
    let update: (GCKMediaStatus?) -> Void

    init(service: GCKRemoteMediaClient, update: @escaping (GCKMediaStatus?) -> Void) {
        self.update = update
        super.init()
        service.add(self)
    }

    func value(from status: GCKMediaStatus) -> Float {
        status.playbackRate
    }

    func makeRequest(for value: Float, using service: GCKRemoteMediaClient) -> GCKRequest {
        service.setPlaybackRate(value)
    }

    func remoteMediaClient(_ client: GCKRemoteMediaClient, didUpdate mediaStatus: GCKMediaStatus?) {
        update(mediaStatus)
    }
}

final class RepeatModeRecipe: NSObject, SynchronizerRecipe, GCKRemoteMediaClientListener {
    let update: (GCKMediaStatus?) -> Void

    init(service: GCKRemoteMediaClient, update: @escaping (GCKMediaStatus?) -> Void) {
        self.update = update
        super.init()
        service.add(self)
    }

    func value(from status: GCKMediaStatus) -> CastRepeatMode {
        CastRepeatMode(rawMode: status.queueRepeatMode) ?? .off
    }

    func makeRequest(for value: CastRepeatMode, using remoteMediaClient: GCKRemoteMediaClient) -> GCKRequest {
        remoteMediaClient.queueSetRepeatMode(value.rawMode())
    }

    func remoteMediaClient(_ client: GCKRemoteMediaClient, didUpdate mediaStatus: GCKMediaStatus?) {
        update(mediaStatus)
    }
}

final class ActiveTracksRecipe: NSObject, SynchronizerRecipe, GCKRemoteMediaClientListener {
    let update: (GCKMediaStatus?) -> Void

    init(service: GCKRemoteMediaClient, update: @escaping (GCKMediaStatus?) -> Void) {
        self.update = update
        super.init()
        service.add(self)
    }

    func value(from status: GCKMediaStatus) -> [CastMediaTrack] {
        Self.activeTracks(from: status)
    }

    func makeRequest(for value: [CastMediaTrack], using remoteMediaClient: GCKRemoteMediaClient) -> GCKRequest {
        remoteMediaClient.setActiveTrackIDs(value.map { NSNumber(value: $0.trackIdentifier) })
    }

    func remoteMediaClient(_ client: GCKRemoteMediaClient, didUpdate mediaStatus: GCKMediaStatus?) {
        update(mediaStatus)
    }

    private static func activeTracks(from mediaStatus: GCKMediaStatus?) -> [CastMediaTrack] {
        guard let mediaStatus, let rawTracks = mediaStatus.mediaInformation?.mediaTracks, let activeTrackIDs = mediaStatus.activeTrackIDs else {
            return []
        }
        // swiftlint:disable:next legacy_objc_type
        return rawTracks.filter { activeTrackIDs.contains(NSNumber(value: $0.identifier)) }.map { .init(rawTrack: $0) }
    }
}

extension ObservableObject where ObjectWillChangePublisher == ObservableObjectPublisher {
    typealias ReceiverState<Recipe: SynchronizerRecipe> = _ReceiverState<Self, Recipe>
    typealias MediaStatus = _MediaStatus<Self>
}

@propertyWrapper
final class _MediaStatus<Instance>: NSObject, GCKRemoteMediaClientListener where Instance: ObservableObject, Instance.ObjectWillChangePublisher == ObservableObjectPublisher {
    private let remoteMediaClient: GCKRemoteMediaClient

    private weak var enclosingInstance: Instance?

    @Published private var value: GCKMediaStatus? {
        willSet {
            enclosingInstance?.objectWillChange.send()
        }
    }

    static subscript(
        _enclosingInstance instance: Instance,
        wrapped wrappedKeyPath: ReferenceWritableKeyPath<Instance, GCKMediaStatus?>,
        storage storageKeyPath: ReferenceWritableKeyPath<Instance, _MediaStatus>
    ) -> GCKMediaStatus? {
        get {
            let synchronizer = instance[keyPath: storageKeyPath]
            synchronizer.enclosingInstance = instance
            return synchronizer.value
        }
        set {}
    }

    @available(*, unavailable, message: "@ReceiverState can only be applied to classes")
    var wrappedValue: GCKMediaStatus? {
        get { fatalError() }
        set { fatalError() }
    }

    init(remoteMediaClient: GCKRemoteMediaClient) {
        self.remoteMediaClient = remoteMediaClient
        self.value = remoteMediaClient.mediaStatus
        super.init()
        remoteMediaClient.add(self)
    }

    func remoteMediaClient(_ client: GCKRemoteMediaClient, didUpdate mediaStatus: GCKMediaStatus?) {
        value = mediaStatus
    }
}

@propertyWrapper
final class _ReceiverState<Instance, Recipe>: NSObject, GCKRequestDelegate where Recipe: SynchronizerRecipe, Instance: ObservableObject, Instance.ObjectWillChangePublisher == ObservableObjectPublisher {
    private let service: Recipe.Service
    private let defaultValue: Recipe.Value

    private lazy var recipe: Recipe = {
        .init(service: service) { [weak self] status in
            self?.update(with: status)
        }
    }()

    private weak var currentRequest: GCKRequest?
    private var pendingValue: Recipe.Value?

    private var isConnected: Bool {
        service.isConnected
    }

    private weak var enclosingInstance: Instance?

    @Published private var value: Recipe.Value {
        willSet {
            enclosingInstance?.objectWillChange.send()
        }
    }

    var projectedValue: AnyPublisher<Recipe.Value, Never> {
        $value.eraseToAnyPublisher()
    }

    static subscript(
        _enclosingInstance instance: Instance,
        wrapped wrappedKeyPath: ReferenceWritableKeyPath<Instance, Recipe.Value>,
        storage storageKeyPath: ReferenceWritableKeyPath<Instance, _ReceiverState>
    ) -> Recipe.Value {
        get {
            let synchronizer = instance[keyPath: storageKeyPath]
            synchronizer.enclosingInstance = instance
            return synchronizer.value
        }
        set {
            let synchronizer = instance[keyPath: storageKeyPath]
            synchronizer.enclosingInstance = instance
            guard synchronizer.isConnected, synchronizer.value != newValue else { return }
            synchronizer.value = newValue
            synchronizer.requestUpdate(to: newValue)
        }
    }

    @available(*, unavailable, message: "@ReceiverState can only be applied to classes")
    var wrappedValue: Recipe.Value {
        get { fatalError() }
        set { fatalError() }
    }

    init(service: Recipe.Service, defaultValue: Recipe.Value) {
        self.service = service
        self.value = defaultValue
        self.defaultValue = defaultValue
        super.init()
        self.value = recipe.value(from: service.status, defaultValue: defaultValue)
    }

    func requestUpdate(to value: Recipe.Value) {
        if currentRequest == nil {
            currentRequest = makeRequest(to: value)
        }
        else {
            pendingValue = value
        }
    }

    private func update(with status: Recipe.Service.Status?) {
        guard currentRequest == nil else { return }
        value = recipe.value(from: status, defaultValue: defaultValue)
    }

    private func makeRequest(to value: Recipe.Value) -> GCKRequest? {
        self.value = value
        let request = recipe.makeRequest(for: value, using: service)
        request.delegate = self
        return request
    }

    func requestDidComplete(_ request: GCKRequest) {
        if let pendingValue {
            currentRequest = makeRequest(to: pendingValue)
            self.pendingValue = nil
        }
    }
}

/// A cast player.
public final class CastPlayer: NSObject, ObservableObject {
    private let remoteMediaClient: GCKRemoteMediaClient

    private let seek: CastSeek

    @MediaStatus private var synchronizedMediaStatus: GCKMediaStatus?

    @ReceiverState<ShouldPlayRecipe> private var synchronizedShouldPlay: Bool
    @ReceiverState<RepeatModeRecipe> private var synchronizedRepeatMode: CastRepeatMode
    @ReceiverState<PlaybackSpeedRecipe> private var synchronizedPlaybackSpeed: Float
    @ReceiverState<ActiveTracksRecipe> private var synchronizedActiveTracks: [CastMediaTrack]

    public var shouldPlay: Bool {
        get {
            synchronizedShouldPlay
        }
        set {
            synchronizedShouldPlay = newValue
        }
    }

    /// The mode with which the player repeats playback of items in its queue.
    public var repeatMode: CastRepeatMode {
        get {
            synchronizedRepeatMode
        }
        set {
            synchronizedRepeatMode = newValue
        }
    }

    public var isActive: Bool {
        synchronizedMediaStatus != nil
    }

    /// The queue managing player items.
    public let queue: CastQueue

    var configuration: CastConfiguration

    init?(remoteMediaClient: GCKRemoteMediaClient?, configuration: CastConfiguration) {
        guard let remoteMediaClient else { return nil }

        self.remoteMediaClient = remoteMediaClient
        self.configuration = configuration

        queue = .init(remoteMediaClient: remoteMediaClient)
        seek = .init(remoteMediaClient: remoteMediaClient)

        _synchronizedMediaStatus = MediaStatus(remoteMediaClient: remoteMediaClient)
        _synchronizedShouldPlay = ReceiverState(service: remoteMediaClient, defaultValue: false)
        _synchronizedRepeatMode = ReceiverState(service: remoteMediaClient, defaultValue: .off)
        _synchronizedActiveTracks = ReceiverState(service: remoteMediaClient, defaultValue: [])
        _synchronizedPlaybackSpeed = ReceiverState(service: remoteMediaClient, defaultValue: 1)

        super.init()
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
    /// The currently allowed playback speed range.
    var playbackSpeedRange: ClosedRange<Float> {
        synchronizedMediaStatus?.mediaInformation?.streamType == .buffered ? 0.5...2 : 1...1
    }

    /// The currently applicable playback speed.
    var playbackSpeed: Float {
        get {
            synchronizedPlaybackSpeed
        }
        set {
            synchronizedPlaybackSpeed = newValue
        }
    }
}

public extension CastPlayer {
    /// The set of media characteristics for which a media selection is available.
    var mediaSelectionCharacteristics: Set<AVMediaCharacteristic> {
        Set(Self.tracks(from: synchronizedMediaStatus).compactMap(\.mediaCharacteristic))
    }

    private static func tracks(from mediaStatus: GCKMediaStatus?) -> [CastMediaTrack] {
        guard let rawTracks = mediaStatus?.mediaInformation?.mediaTracks else { return [] }
        return rawTracks.map { .init(rawTrack: $0) }
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
        var activeTracks = synchronizedActiveTracks
        activeTracks.removeAll { $0.mediaCharacteristic == characteristic }
        switch mediaOption {
        case .off:
            break
        case let .on(track):
            activeTracks.append(track)
        }
        synchronizedActiveTracks = activeTracks
    }

    /// The list of media options associated with a characteristic.
    ///
    /// - Parameter characteristic: The characteristic.
    /// - Returns: The list of options associated with the characteristic.
    ///
    /// Use `mediaSelectionCharacteristics` to retrieve available characteristics.
    func mediaSelectionOptions(for characteristic: AVMediaCharacteristic) -> [CastMediaSelectionOption] {
        let tracks = Self.tracks(from: synchronizedMediaStatus).filter { $0.mediaCharacteristic == characteristic }
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
            guard let track = synchronizedActiveTracks.first(where: { $0.mediaCharacteristic == characteristic }) else { return .off }
            return .on(track)
        default:
            return .off
        }
    }
}

public extension CastPlayer {
    /// Player state.
    var state: GCKMediaPlayerState {
        synchronizedMediaStatus?.playerState ?? .unknown
    }

    /// Media information.
    var mediaInformation: GCKMediaInformation? {
        synchronizedMediaStatus?.mediaInformation
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

private extension CastPlayer {
    static func isValidTimeInterval(_ timeInterval: TimeInterval) -> Bool {
        GCKIsValidTimeInterval(timeInterval) && timeInterval != .infinity
    }
}
