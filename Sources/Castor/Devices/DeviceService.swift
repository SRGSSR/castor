//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

protocol DeviceService {
    associatedtype Device

    var device: Device { get }

    var volumeRange: ClosedRange<Float> { get }

    var canAdjustVolume: Bool { get }
    var canMute: Bool { get }
}
