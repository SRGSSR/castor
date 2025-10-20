//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine

/// An observable object that manages a Cast device.
@MainActor
public final class CastDeviceManager<Device>: ObservableObject {
    private let service: any DeviceService

    @MutableReceiverState private var _volume: Float
    @MutableReceiverState private var _isMuted: Bool

    /// The device.
    public let device: Device

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
        service.volumeRange
    }

    /// A Boolean indicating whether the volume of the device can be adjusted.
    public var canAdjustVolume: Bool {
        service.canAdjustVolume
    }

    /// A Boolean indicating whether the device can be muted.
    public var canMute: Bool {
        service.canMute
    }

    init?<Service>(service: Service?) where Service: DeviceService, Service.Device == Device {
        guard let service else { return nil }

        self.service = service
        self.device = service.device

        __volume = .init(service: service, recipe: Service.VolumeRecipe.self)
        __isMuted = .init(service: service, recipe: Service.MutedRecipe.self)
    }
}
