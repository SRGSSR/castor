//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import GoogleCast

struct CastContext: Equatable {
    let devices: [CastDevice]
    let multizoneDevices: [CastMultizoneDevice]
    let session: GCKCastSession?
}
