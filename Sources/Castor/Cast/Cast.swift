//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Combine
import Foundation
import GoogleCast
import SwiftUI

/// An observable object that manages all aspects of Google Cast.
///
/// `Cast` is a top-level type responsible for handling available devices, active sessions, and the volume of the
/// current device.
///
/// Create and store a `Cast` instance in your top-level application view, then use ``SwiftUICore/View/supportsCast(_:with:)-(_,CastDelegate)``
/// to register a delegate. The delegate can respond to session start and end events by presenting or dismissing views related
/// to the current cast session, typically through a router.
///
/// Once a session is established, use ``Cast/player`` to load content and control playback.
@MainActor
public final class Cast: NSObject, ObservableObject {
    /// The package version.
    public static let version = PackageInfo.version

    weak var castable: Castable?
    weak var delegate: CastDelegate?

    private let context = GCKCastContext.sharedInstance()
    private var targetResumeState: CastResumeState?

    @ReceiverState(DevicesRecipe.self)
    private var _devices

    @CurrentDevice private var _currentDevice: CastDevice?

    @ReceiverState(MultizoneDevicesRecipe.self)
    private var _multizoneDevices

    @MutableReceiverState(VolumeRecipe.self)
    private var _volume

    @MutableReceiverState(MutedRecipe.self)
    private var _isMuted

    private var currentSession: GCKCastSession? {
        didSet {
            player = .init(remoteMediaClient: currentSession?.remoteMediaClient, configuration: configuration)
            __multizoneDevices.bind(to: currentSession)
        }
    }

    /// The cast configuration.
    public var configuration: CastConfiguration {
        didSet {
            player?.configuration = configuration
        }
    }

    /// A Boolean setting whether the audio output of the current device must be muted.
    public var isMuted: Bool {
        get {
            _isMuted || _volume == 0
        }
        set {
            guard canMute, _isMuted != newValue || volume == 0 else { return }
            _isMuted = newValue
            if !newValue, volume == 0 {
                volume = 0.1
            }
        }
    }

    /// The audio output volume of the current device.
    ///
    /// Valid values range from 0 (silent) to 1 (maximum volume).
    public var volume: Float {
        get {
            _volume
        }
        set {
            guard canAdjustVolume, _volume != newValue, volumeRange.contains(newValue) else { return }
            _volume = newValue
        }
    }

    /// The allowed range for the volume of the current device.
    public var volumeRange: ClosedRange<Float> {
        currentSession?.traits?.volumeRange ?? 0...0
    }

    /// A Boolean indicating whether the volume of the current device can be adjusted.
    public var canAdjustVolume: Bool {
        currentSession?.isFixedVolume == false
    }

    /// A Boolean indicating whether the current device can be muted.
    public var canMute: Bool {
        currentSession?.supportsMuting == true
    }

    /// The current device.
    ///
    /// Does nothing if set to `nil` or to a device that does not belong to ``Cast/devices``.
    public var currentDevice: CastDevice? {
        get {
            _currentDevice
        }
        set {
            guard let newValue, devices.contains(newValue) else { return }
            _currentDevice = newValue
        }
    }

    /// The player.
    ///
    /// Use this object to load content and control playback.
    @Published public private(set) var player: CastPlayer?

    /// The list of devices discovered on the local network.
    public var devices: [CastDevice] {
        _devices
    }

    /// The list of multizone devices discovered on the local network.
    public var multizoneDevices: [CastMultizoneDevice] {
        _multizoneDevices.count > 1 ? _multizoneDevices : []
    }

    /// The current connection state with a device.
    @Published public private(set) var connectionState: GCKConnectionState

    /// Creates an instance.
    ///
    /// - Parameter configuration: The Cast configuration.
    public init(configuration: CastConfiguration = .init()) {
        self.configuration = configuration
        currentSession = context.sessionManager.currentCastSession
        connectionState = context.sessionManager.connectionState

        player = .init(remoteMediaClient: currentSession?.remoteMediaClient, configuration: configuration)

        __currentDevice = .init(service: context.sessionManager)

        super.init()

        __devices.bind(to: context.discoveryManager)
        __volume.bind(to: context.sessionManager)
        __isMuted.bind(to: context.sessionManager)

        context.sessionManager.add(self)

        assert(
            GCKCastContext.isSharedInstanceInitialized(),
            "Initialize the Cast context by following instructions at https://developers.google.com/cast/docs/ios_sender/integrate"
        )
        context.sessionManager.publisher(for: \.connectionState)
            .removeDuplicates()
            .assign(to: &$connectionState)
    }

    /// Starts a new session using the specified device.
    ///
    /// - Parameter device: The device to connect to for this session.
    public func startSession(with device: CastDevice) {
        _currentDevice = device
    }

    /// Ends the current session and stops casting if a single sender device is connected.
    public func endSession() {
        _currentDevice = nil
    }

    /// Checks whether the specified device is currently casting.
    ///
    /// - Parameter device: The device to check.
    /// - Returns: `true` if the device is casting; otherwise, `false`.
    public func isCasting(on device: CastDevice) -> Bool {
        _currentDevice == device
    }
}

extension Cast: @preconcurrency GCKSessionManagerListener {
    // swiftlint:disable:next missing_docs
    public func sessionManager(_ sessionManager: GCKSessionManager, willStart session: GCKCastSession) {
        currentSession = session
    }

    // swiftlint:disable:next missing_docs
    public func sessionManager(_ sessionManager: GCKSessionManager, didStart session: GCKCastSession) {
        currentSession = session
        if let resumeState = targetResumeState {
            resume(from: resumeState)
            targetResumeState = nil
        }
        else {
            if let resumeState = castable?.castStartSession() {
                resume(from: resumeState)
            }
            delegate?.castStartSession()
        }
    }

    // swiftlint:disable:next missing_docs
    public func sessionManager(_ sessionManager: GCKSessionManager, didResumeCastSession session: GCKCastSession) {
        currentSession = session
    }

    // swiftlint:disable:next missing_docs
    public func sessionManager(
        _ sessionManager: GCKSessionManager,
        didSuspend session: GCKCastSession,
        with reason: GCKConnectionSuspendReason
    ) {
        currentSession = nil
    }

    // swiftlint:disable:next missing_docs
    public func sessionManager(_ sessionManager: GCKSessionManager, willEnd session: GCKCastSession) {
        let resumeState = session.remoteMediaClient?.resumeState()
        if currentDevice == nil {
            delegate?.castEndSession(with: resumeState)
            castable?.castEndSession(with: resumeState)
        }
        else {
            targetResumeState = resumeState
        }
    }

    // swiftlint:disable:next missing_docs
    public func sessionManager(_ sessionManager: GCKSessionManager, didEnd session: GCKCastSession, withError error: (any Error)?) {
        currentSession = sessionManager.currentCastSession
    }

    // swiftlint:disable:next missing_docs
    public func sessionManager(
        _ sessionManager: GCKSessionManager,
        didFailToStart session: GCKCastSession,
        withError error: any Error
    ) {
        currentSession = nil
    }

    private func resume(from state: CastResumeState) {
        guard let player else { return }
        player.loadItems(from: state.assets, with: state.options)
        state.mediaSelectionCharacteristics.forEach { characteristic in
            if let language = state.mediaSelectionLanguage(for: characteristic) {
                player.setMediaSelectionPreference(.on(languages: language), for: characteristic)
            }
            else {
                player.setMediaSelectionPreference(.off, for: characteristic)
            }
        }
    }
}
