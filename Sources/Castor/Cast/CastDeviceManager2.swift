//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import GoogleCast

public protocol CastDeviceService {
    associatedtype Device

    var device: Device { get }

    var volumeRange: ClosedRange<Float> { get }

    var canAdjustVolume: Bool { get }
    var canMute: Bool { get }
}

protocol CastDeviceManagerConfiguration2 {
    associatedtype Service: CastDeviceService

    associatedtype VolumeRecipe: MutableReceiverStateRecipe2 where VolumeRecipe.Service == Service, VolumeRecipe.Value == Float
    associatedtype MutedRecipe: MutableReceiverStateRecipe2 where MutedRecipe.Service == Service, MutedRecipe.Value == Bool
}

struct MainDeviceService: CastDeviceService {
    let session: GCKCastSession

    var device: GCKDevice {
        session.device
    }

    var volumeRange: ClosedRange<Float> {
        session.traits?.volumeRange ?? 0...0
    }

    var canAdjustVolume: Bool {
        session.isFixedVolume
    }

    var canMute: Bool {
        session.supportsMuting
    }
}

struct ZoneDeviceService: CastDeviceService {
    let device: GCKMultizoneDevice

    var volumeRange: ClosedRange<Float> {
        0...1
    }

    var canAdjustVolume: Bool {
        true
    }

    var canMute: Bool {
        true
    }
}

struct MainConfiguration2: CastDeviceManagerConfiguration2 {
    typealias Service = MainDeviceService
    typealias VolumeRecipe = VolumeRecipe2
    typealias MutedRecipe = MutedRecipe2
}

struct ZoneConfiguration2: CastDeviceManagerConfiguration2 {
    typealias Service = ZoneDeviceService
    typealias VolumeRecipe = ZoneVolumeRecipe2
    typealias MutedRecipe = ZoneMutedRecipe2
}

@MainActor
public final class CastDeviceManager2<Device>: ObservableObject {
    @MutableReceiverState2
    private var _volume: Float = 0

    @MutableReceiverState2
    private var _isMuted = false

    private let service: any CastDeviceService
    private let device: Device

    var volumeRange: ClosedRange<Float> {
        service.volumeRange
    }

    var canAdjustVolume: Bool {
        service.canAdjustVolume
    }

    var canMute: Bool {
        service.canMute 
    }

    init<Configuration, Service>(
        configuration: Configuration.Type,
        service: Service
    ) where Configuration: CastDeviceManagerConfiguration2, Service: CastDeviceService, Configuration.Service == Service, Service.Device == Device {
        self.service = service
        self.device = service.device

        __volume.synchronize(using: Configuration.VolumeRecipe.self, service: service)
        __isMuted.synchronize(using: Configuration.MutedRecipe.self, service: service)
    }
}

@MainActor
func testInternalCreation() {
    let _ = CastDeviceManager2(
        configuration: MainConfiguration2.self,
        service: MainDeviceService(session: .init())
    )
    let _ = CastDeviceManager2(
        configuration: ZoneConfiguration2.self,
        service: ZoneDeviceService(device: .init(coder: .init())!)
    )
}
