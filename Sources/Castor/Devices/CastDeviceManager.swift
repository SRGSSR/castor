//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import GoogleCast

/// An observable object that manages a Cast device.
@MainActor
public final class CastDeviceManager: ObservableObject {
    @ReceiverState private var _currentSession: GCKCastSession?

    @MutableReceiverState private var _volume: Float
    @MutableReceiverState private var _isMuted: Bool

    /// A Boolean value indicating whether the audio output of the device is muted.
    ///
    /// A device whose volume is zero is reported as muted. Unmuting such a device sets its volume to 0.1.
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

    /// The audio output volume of the device.
    ///
    /// Valid values range from 0 (silent) to 1 (maximum volume). Does nothing if the volume cannot be adjusted or if the
    /// value lies outside ``volumeRange``.
    public var volume: Float {
        get {
            _volume
        }
        set {
            guard canAdjustVolume, _volume != newValue, volumeRange.contains(newValue) else { return }
            _volume = newValue
        }
    }

    /// The allowed range for the volume of the device.
    public var volumeRange: ClosedRange<Float> {
        guard let traits = _currentSession?.traits else { return 0...0 }
        return traits.volumeRange
    }

    /// A Boolean value indicating whether the volume of the device can be adjusted.
    public var canAdjustVolume: Bool {
        guard let traits = _currentSession?.traits else { return false }
        return !traits.isFixedVolume()
    }

    /// A Boolean value indicating whether the device can be muted.
    public var canMute: Bool {
        guard let traits = _currentSession?.traits else { return false }
        return traits.supportsMuting
    }

    init(sessionManager: GCKSessionManager, multizoneDevice: CastMultizoneDevice?) {
        // Use the current session to determine device capabilities, including those of associated multi-zone devices.
        __currentSession = .init(service: sessionManager, recipe: CurrentSessionRecipe.self)

        if let multizoneDevice {
            let service = MultizoneDeviceService(device: multizoneDevice, sessionManager: sessionManager)
            __volume = .init(service: service, recipe: MultizoneVolumeRecipe.self)
            __isMuted = .init(service: service, recipe: MultizoneMutedRecipe.self)
        }
        else {
            __volume = .init(service: sessionManager, recipe: MainVolumeRecipe.self)
            __isMuted = .init(service: sessionManager, recipe: MainMutedRecipe.self)
        }
    }
}
