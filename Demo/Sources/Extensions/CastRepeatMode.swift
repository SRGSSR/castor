//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Castor
import PillarboxPlayer

extension CastRepeatMode {
    init(from repeatMode: RepeatMode) {
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
