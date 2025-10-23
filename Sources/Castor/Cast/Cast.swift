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
    private var cancellables = Set<AnyCancellable>()

    @ReceiverState private var _devices: [CastDevice]
    @ReceiverState private var _multizoneDevices: [CastMultizoneDevice]
    @ReceiverState private var _currentSession: GCKCastSession?
    @CurrentDevice private var _currentDevice: CastDevice?

    /// The Cast configuration.
    public var configuration: CastConfiguration {
        didSet {
            player?.configuration = configuration
        }
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

    /// The list of multi-zone devices discovered on the local network.
    public var multizoneDevices: [CastMultizoneDevice] {
        _multizoneDevices.count > 1 ? _multizoneDevices : []
    }

    /// The current connection state with a device.
    @Published public private(set) var connectionState: GCKConnectionState

    /// Creates an instance.
    ///
    /// - Parameter configuration: The Cast configuration.
    public init(configuration: CastConfiguration = .init()) {
        assert(
            GCKCastContext.isSharedInstanceInitialized(),
            "Initialize the Cast context by following instructions at https://developers.google.com/cast/docs/ios_sender/integrate"
        )

        self.configuration = configuration

        player = .init(remoteMediaClient: context.sessionManager.currentCastSession?.remoteMediaClient, configuration: configuration)
        connectionState = context.sessionManager.connectionState

        __devices = .init(service: context.discoveryManager, recipe: DevicesRecipe.self)
        __multizoneDevices = .init(service: context.sessionManager, recipe: MultizoneDevicesRecipe.self)
        __currentSession = .init(service: context.sessionManager, recipe: CurrentSessionRecipe.self)
        __currentDevice = .init(service: context.sessionManager)

        super.init()

        configurePlayerUpdatePublisher()

        context.sessionManager.add(self)
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

    /// Gets a device manager associated with a device.
    ///
    /// - Parameter multizoneDevice: The multi-zone device to retrieve a device manager for, or `nil` for the main device.
    public func deviceManager(forMultizoneDevice multizoneDevice: CastMultizoneDevice? = nil) -> CastDeviceManager {
        .init(sessionManager: context.sessionManager, multizoneDevice: multizoneDevice)
    }

    private func configurePlayerUpdatePublisher() {
        $_currentSession.sink { [weak self] session in
            guard let self, session?.remoteMediaClient != player?.remoteMediaClient else { return }
            player = .init(remoteMediaClient: session?.remoteMediaClient, configuration: configuration)
        }
        .store(in: &cancellables)
    }
}

extension Cast: @preconcurrency GCKSessionManagerListener {
    // swiftlint:disable:next missing_docs
    public func sessionManager(_ sessionManager: GCKSessionManager, didStart session: GCKCastSession) {
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
