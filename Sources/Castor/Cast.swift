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
public final class Cast: NSObject, ObservableObject {
    /// The package version.
    public static let version = PackageInfo.version

    private let context = GCKCastContext.sharedInstance()

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

    @ReceiverState(DevicesRecipe.self)
    private var synchronizedDevices

    @MutableReceiverState(CurrentDeviceRecipe.self)
    private var synchronizedCurrentDevice

    @MutableReceiverState(VolumeRecipe.self)
    private var synchronizedVolume

    @MutableReceiverState(MutedRecipe.self)
    private var synchronizedIsMuted

    /// A Boolean setting whether the audio output of the current device must be muted.
    public var isMuted: Bool {
        get {
            synchronizedIsMuted || synchronizedVolume == 0
        }
        set {
            guard synchronizedIsMuted != newValue || volume == 0 else { return }
            synchronizedIsMuted = newValue
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
            synchronizedVolume
        }
        set {
            guard synchronizedVolume != newValue else { return }
            synchronizedVolume = newValue
        }
    }

    /// The allowed range for volume values.
    public var volumeRange: ClosedRange<Float> {
        canAdjustVolume ? 0...1 : 0...0
    }

    /// A Boolean indicating whether the volume can be adjusted.
    public var canAdjustVolume: Bool {
        currentSession?.isFixedVolume() == false
    }

    /// A Boolean indicating whether the device can be muted.
    public var canMute: Bool {
        currentSession?.supportsMuting() == true
    }

    /// The current device.
    ///
    /// Ends the session if set to `nil`. Does nothing if the device does not belong to the device list.
    public var currentDevice: CastDevice? {
        get {
            synchronizedCurrentDevice
        }
        set {
            if let newValue, !devices.contains(newValue) {
                return
            }
            synchronizedCurrentDevice = newValue
        }
    }

    /// The player.
    @Published public private(set) var player: CastPlayer?

    /// The devices found in the local network.
    public var devices: [CastDevice] {
        synchronizedDevices
    }

    /// The connection state to a device.
    @Published public private(set) var connectionState: GCKConnectionState

    /// Default initializer.
    ///
    /// - Parameter configuration: The configuration to apply to the cast.
    public init(configuration: CastConfiguration = .default) {
        self.configuration = configuration
        currentSession = context.sessionManager.currentCastSession
        connectionState = context.sessionManager.connectionState

        player = .init(remoteMediaClient: currentSession?.remoteMediaClient, configuration: configuration)

        super.init()

        _synchronizedDevices.attach(to: context.discoveryManager)
        _synchronizedCurrentDevice.attach(to: context.sessionManager)
        _synchronizedVolume.attach(to: context.sessionManager)
        _synchronizedIsMuted.attach(to: context.sessionManager)

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
        currentDevice = nil
    }

    /// Check if the given device if currently casting.
    /// - Parameter device: The device.
    /// - Returns: `true` if the given device is casting, `false` otherwise.
    public func isCasting(on device: CastDevice) -> Bool {
        currentDevice == device
    }
}

extension Cast: GCKSessionManagerListener {
    // swiftlint:disable:next missing_docs
    public func sessionManager(_ sessionManager: GCKSessionManager, willStart session: GCKCastSession) {
        currentSession = session
    }

    // swiftlint:disable:next missing_docs
    public func sessionManager(_ sessionManager: GCKSessionManager, didStart session: GCKCastSession) {
        currentSession = session
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
