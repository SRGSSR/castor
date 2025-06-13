//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import GoogleCast

extension GCKMediaStatus {
    var isConnected: Bool {
        queueItemCount != 0
    }
}
