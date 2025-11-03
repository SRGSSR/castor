//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import GoogleCast

struct MultizoneDeviceService {
    let device: CastMultizoneDevice
    let sessionManager: GCKSessionManager

    var rawDevice: GCKMultizoneDevice {
        device.rawDevice
    }
}
