//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import GoogleCast

extension GCKCastSession {
    func supportsMuting() -> Bool {
        traits?.supportsMuting == true
    }

    func isFixedVolume() -> Bool {
        traits?.isFixedVolume() == true
    }
}
