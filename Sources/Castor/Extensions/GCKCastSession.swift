//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import GoogleCast

extension GCKCastSession: ReceiverRequester {
    var canRequest: Bool {
        traits?.isFixedVolume() == false
    }
}
