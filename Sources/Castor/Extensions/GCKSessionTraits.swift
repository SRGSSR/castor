//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import GoogleCast

extension GCKSessionTraits {
    var volumeRange: ClosedRange<Float> {
        minimumVolume...maximumVolume
    }
}
