//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import Foundation
import GoogleCast
import SwiftUI

/// This object that handles everything related to Google Cast.
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

    @MutableReceiverState(VolumeRecipe.self)
    private var _volume

    @MutableReceiverState(MutedRecipe.self)
    private var _isMuted

    private var currentSession: GCKCastSession? {
        didSet {
            player = .init(remoteMediaClient: currentSession?.remoteMediaClient, configuration: configuration)
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
            guard _isMuted != newValue || volume == 0 else { return }
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
            guard _volume != newValue else { return }
            _volume = newValue
        }
    }

    /// The allowed range for volume values.
    public var volumeRange: ClosedRange<Float> {
        currentSession?.traits?.volumeRange ?? 0...0
    }

    /// A Boolean indicating whether the volume can be adjusted.
    public var canAdjustVolume: Bool {
        currentSession?.isFixedVolume == false
    }

    /// A Boolean indicating whether the device can be muted.
    public var canMute: Bool {
        currentSession?.supportsMuting == true
    }

    /// The current device.
    ///
    /// Does nothing if set to `nil` or to an item that does not belong to the list.
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
    @Published public private(set) var player: CastPlayer?

    /// The devices found in the local network.
    public var devices: [CastDevice] {
        _devices
    }

    /// The connection state to a device.
    @Published public private(set) var connectionState: GCKConnectionState

    /// Default initializer.
    ///
    /// - Parameter configuration: The configuration to apply to the cast.
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
            .assign(to: &$connectionState)
    }

    /// Starts a new session with the given device.
    /// - Parameter device: The device to use for this session.
    public func startSession(with device: CastDevice) {
        currentDevice = device
    }

    /// Ends the current session and stops casting if one sender device is connected.
    public func endSession() {
        context.sessionManager.endSession()
    }

    /// Check if the given device if currently casting.
    /// - Parameter device: The device.
    /// - Returns: `true` if the given device is casting, `false` otherwise.
    public func isCasting(on device: CastDevice) -> Bool {
        currentDevice == device
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
        if let player, let delegate {
            if let resumeState = targetResumeState {
                player.loadItems(from: resumeState.assets, with: .init(startTime: resumeState.time, startIndex: resumeState.index))
                targetResumeState = nil
            }
            else if let resumeState = castable?.castResumeState() {
                player.loadItems(from: resumeState.assets, with: .init(startTime: resumeState.time, startIndex: resumeState.index))
            }
            else {
                player.removeAllItems()
            }
            delegate.castStartSession()
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
        if let delegate, let resumeState = player?.resumeState(with: delegate) {
            if _currentDevice == nil {
                delegate.castEndSession(with: resumeState)
            }
            else {
                targetResumeState = resumeState
            }
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
}
