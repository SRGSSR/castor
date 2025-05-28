//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import GoogleCast

extension GCKCastSession {
    var canAdjustVolume: Bool {
        device.hasCapabilities(.masterOrFixedVolume)
    }
}
