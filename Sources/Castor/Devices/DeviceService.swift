//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

protocol DeviceService {
    associatedtype Device
    
    associatedtype VolumeRecipe: MutableReceiverStateRecipe where VolumeRecipe.Value == Float, VolumeRecipe.Service == Self
    associatedtype MutedRecipe: MutableReceiverStateRecipe where MutedRecipe.Value == Bool, MutedRecipe.Service == Self

    var device: Device { get }

    var volumeRange: ClosedRange<Float> { get }

    var canAdjustVolume: Bool { get }
    var canMute: Bool { get }
}
