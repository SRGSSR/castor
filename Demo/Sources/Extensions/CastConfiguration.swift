//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Castor
import Foundation

extension CastConfiguration {
    static var standard: Self {
        let userDefaults = UserDefaults.standard
        return .init(
            backwardSkipInterval: userDefaults.backwardSkipInterval,
            forwardSkipInterval: userDefaults.forwardSkipInterval
        )
    }
}
