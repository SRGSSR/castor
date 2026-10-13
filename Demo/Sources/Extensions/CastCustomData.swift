//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Castor
import PillarboxPlayer
import PillarboxStandardConnector

extension CastCustomData {
    var playerData: PlayerData<EmptyCustomData>? {
        decoded(as: PlayerData.self)
    }
}
