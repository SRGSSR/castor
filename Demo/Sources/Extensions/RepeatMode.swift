//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Castor
import PillarboxPlayer

extension RepeatMode {
    init(from repeatMode: CastRepeatMode) {
        switch repeatMode {
        case .off:
            self = .off
        case .one:
            self = .one
        case .all:
            self = .all
        }
    }
}
