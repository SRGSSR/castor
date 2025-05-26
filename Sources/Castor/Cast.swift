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

            if let currentSession {
                volumeSynchronizer = .init(sessionManager: context.sessionManager, session: currentSession, builder: { session, volume in
                    session.setDeviceVolume(volume)
                }, parser: { volume, _ in
                    volume
                })
                volumeSynchronizer?.update = { [weak self] volume in
                    self?._volume = volume
                }

                isMutedSynchronizer = .init(sessionManager: context.sessionManager, session: currentSession, builder: { session, isMuted in
                    session.setDeviceMuted(isMuted)
                }, parser: { _, isMuted in
                    isMuted
                })
                isMutedSynchronizer?.update = { [weak self] isMuted in
                    self?._isMuted = isMuted
                }
            }
            else {
                volumeSynchronizer = nil
                isMutedSynchronizer = nil
            }
        }
    }

    private var targetDevice: CastDevice?

    /// The cast configuration.
    public var configuration: CastConfiguration {
        didSet {
            player?.configuration = configuration
        }
    }

    @Published private var _volume: Float
    @Published private var _isMuted: Bool

    private var volumeSynchronizer: DeviceSynchronizer<Float>?
    private var isMutedSynchronizer: DeviceSynchronizer<Bool>?

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
            isMutedSynchronizer?.requestUpdate(to: newValue)
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
            volumeSynchronizer?.requestUpdate(to: newValue)
        }
    }

    /// The allowed range for volume values.
    public var volumeRange: ClosedRange<Float> {
        volumeSynchronizer != nil ? 0...1 : 0...0
    }

    /// A Boolean indicating whether the volume/mute can be adjusted.
    public var canAdjustVolume: Bool {
        guard let currentSession else { return false }
        return Self.canAdjustVolume(for: currentSession)
    }

    /// The current device.
    ///
    /// Ends the session if set to `nil`.
    ///
    /// > Important: On iOS 18.3 and below use ``currentDeviceSelection`` to manage selection in a `List`.
    @Published public var currentDevice: CastDevice? {
        didSet {
            if let currentDevice {
                moveSession(from: oldValue, to: currentDevice)
            }
            else {
                endSession()
            }
        }
    }

    /// A binding to the current device, for use as `List` selection.
    @available(iOS, introduced: 16.0, deprecated: 18.4, message: "Use currentDevice instead")
    public var currentDeviceSelection: Binding<CastDevice?> {
        .init { [weak self] in
            self?.currentDevice
        } set: { [weak self] device in
            guard let self, let device else { return }
            currentDevice = device
        }
    }

    /// The player.
    @Published public private(set) var player: CastPlayer?

    /// The devices found in the local network.
    @Published public private(set) var devices: [CastDevice]

    /// The connection state to a device.
    @Published public private(set) var connectionState: GCKConnectionState

    /// Default initializer.
    ///
    /// - Parameter configuration: The configuration to apply to the cast.
    public init(configuration: CastConfiguration = .default) {
        self.configuration = configuration
        currentSession = context.sessionManager.currentCastSession
        connectionState = context.sessionManager.connectionState
        devices = Self.devices(from: context.discoveryManager)
        currentDevice = currentSession?.device.toCastDevice()

        player = .init(remoteMediaClient: currentSession?.remoteMediaClient, configuration: configuration)

        if let currentSession {
            volumeSynchronizer = .init(sessionManager: context.sessionManager, session: currentSession, builder: { session, volume in
                session.setDeviceVolume(volume)
            }, parser: { volume, _ in
                volume
            })

            isMutedSynchronizer = .init(sessionManager: context.sessionManager, session: currentSession, builder: { session, isMuted in
                session.setDeviceMuted(isMuted)
            }, parser: { _, isMuted in
                isMuted
            })
        }
        else {
            volumeSynchronizer = nil
            isMutedSynchronizer = nil
        }

        _volume = currentSession?.currentDeviceVolume ?? 0
        _isMuted = currentSession?.currentDeviceMuted ?? false

        super.init()

        context.discoveryManager.add(self)
        context.discoveryManager.startDiscovery()

        context.sessionManager.add(self)

        volumeSynchronizer?.update = { [weak self] volume in
            self?._volume = volume
        }
        isMutedSynchronizer?.update = { [weak self] isMuted in
            self?._isMuted = isMuted
        }

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
        moveSession(from: currentDevice, to: device)
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

private extension Cast {
    static func canAdjustVolume(for session: GCKCastSession) -> Bool {
        session.device.hasCapabilities(.masterOrFixedVolume)
    }

    func castMuted(from sessionManager: GCKSessionManager, session: GCKCastSession?) -> CastMuted? {
        guard let session, Self.canAdjustVolume(for: session) else { return nil }
        let cast = CastMuted(sessionManager: sessionManager, session: session)
        cast.delegate = self
        return cast
    }

    func castVolume(from sessionManager: GCKSessionManager, session: GCKCastSession?) -> CastVolume? {
        guard let session, Self.canAdjustVolume(for: session) else { return nil }
        let cast = CastVolume(sessionManager: sessionManager, session: session)
        cast.delegate = self
        return cast
    }
}

extension Cast: GCKDiscoveryManagerListener {
    // swiftlint:disable:next missing_docs
    public func didInsert(_ device: GCKDevice, at index: UInt) {
        devices.insert(device.toCastDevice(), at: Int(index))
    }

    // swiftlint:disable:next missing_docs
    public func didRemove(_ device: GCKDevice, at index: UInt) {
        devices.remove(at: Int(index))
    }

    // swiftlint:disable:next missing_docs
    public func didUpdate(_ device: GCKDevice, at index: UInt, andMoveTo newIndex: UInt) {
        devices.move(from: Int(index), to: Int(index))
    }

    // swiftlint:disable:next missing_docs
    public func didUpdate(_ device: GCKDevice, at index: UInt) {
        devices.remove(at: Int(index))
        devices.insert(device.toCastDevice(), at: Int(index))
    }
}

extension Cast: GCKSessionManagerListener {
    // swiftlint:disable:next missing_docs
    public func sessionManager(_ sessionManager: GCKSessionManager, willStart session: GCKCastSession) {
        currentSession = session
        currentDevice = session.device.toCastDevice()
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
        if let targetDevice {
            sessionManager.startSession(with: targetDevice.rawDevice)
            self.targetDevice = nil
        }
        else {
            currentDevice = nil
        }
    }

    // swiftlint:disable:next missing_docs
    public func sessionManager(
        _ sessionManager: GCKSessionManager,
        didFailToStart session: GCKCastSession,
        withError error: any Error
    ) {
        currentSession = nil
        currentDevice = nil
    }
}

private extension Cast {
    static func devices(from discoveryManager: GCKDiscoveryManager) -> [CastDevice] {
        var devices: [CastDevice] = []
        for index in 0..<discoveryManager.deviceCount {
            devices.append(discoveryManager.device(at: index).toCastDevice())
        }
        return devices
    }

    private func moveSession(from previousDevice: CastDevice?, to currentDevice: CastDevice) {
        guard previousDevice != currentDevice else { return }
        if previousDevice != nil {
            targetDevice = currentDevice
            endSession()
        }
        else {
            context.sessionManager.startSession(with: currentDevice.rawDevice)
        }
    }
}

extension Cast: ChangeDelegate {
    func didChange() {
        objectWillChange.send()
    }
}
