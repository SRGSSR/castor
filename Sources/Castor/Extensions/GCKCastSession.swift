//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import GoogleCast

extension GCKCastSession {
    var supportsMuting: Bool {
        traits?.supportsMuting == true
    }

    var isFixedVolume: Bool {
        traits?.isFixedVolume() == true
    }
}
