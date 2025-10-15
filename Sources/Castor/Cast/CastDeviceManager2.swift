//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import GoogleCast

protocol CastDeviceService {
    associatedtype Device

    associatedtype VolumeRecipe: MutableReceiverStateRecipe2 where VolumeRecipe.Service == Self, VolumeRecipe.Value == Float
    associatedtype MutedRecipe: MutableReceiverStateRecipe2 where MutedRecipe.Service == Self, MutedRecipe.Value == Bool

    var device: Device { get }

    var volumeRange: ClosedRange<Float> { get }

    var canAdjustVolume: Bool { get }
    var canMute: Bool { get }
}

struct MainDeviceService: CastDeviceService {
    typealias VolumeRecipe = VolumeRecipe2
    typealias MutedRecipe = MutedRecipe2

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
    typealias VolumeRecipe = ZoneVolumeRecipe2
    typealias MutedRecipe = ZoneMutedRecipe2

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

    init<Service>(service: Service) where Service: CastDeviceService, Service.Device == Device {
        self.service = service
        self.device = service.device

        __volume.synchronize(using: Service.VolumeRecipe.self, service: service)
        __isMuted.synchronize(using: Service.MutedRecipe.self, service: service)
    }
}

@MainActor
func testInternalCreation() {
    let _ = CastDeviceManager2(service: MainDeviceService(session: .init()))
    let _ = CastDeviceManager2(service: ZoneDeviceService(device: .init(coder: .init())!))
}
