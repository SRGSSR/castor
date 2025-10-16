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
    private let sessionManager: GCKSessionManager

    @MutableReceiverState2 private var _volume: Float

    @MutableReceiverState2 private var _isMuted: Bool

    private var currentSession: GCKCastSession? {
        sessionManager.currentCastSession
    }

    /// The device.
    public var device: CastDevice? {
        currentSession?.device.toCastDevice()
    }

    /// A Boolean setting whether the audio output of the device must be muted.
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

    /// The allowed range for the volume of the device.
    public var volumeRange: ClosedRange<Float> {
        currentSession?.traits?.volumeRange ?? 0...0
    }

    /// A Boolean indicating whether the volume of the device can be adjusted.
    public var canAdjustVolume: Bool {
        currentSession?.isFixedVolume == false
    }

    /// A Boolean indicating whether the device can be muted.
    public var canMute: Bool {
        currentSession?.supportsMuting == true
    }

    init(sessionManager: GCKSessionManager) {
        self.sessionManager = sessionManager

        __volume = .init(service: sessionManager, recipe: VolumeRecipe.self)
        __isMuted = .init(service: sessionManager, recipe: MutedRecipe.self)
    }
}
