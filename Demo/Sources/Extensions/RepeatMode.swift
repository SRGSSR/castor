//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Castor
import PillarboxPlayer
import SwiftUI

extension RepeatMode {
    var name: LocalizedStringResource {
        switch self {
        case .off:
            "Off"
        case .one:
            "One"
        case .all:
            "All"
        }
    }

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
