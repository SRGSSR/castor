//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import CoreMedia
import PillarboxPlayer
import PillarboxStandardConnector

typealias StandardChapter = PlayerData<EmptyCustomData>.Chapter

extension StandardChapter {
    var timeRange: CMTimeRange {
        .init(
            start: .init(value: CMTimeValue(startTime), timescale: 1000),
            end: .init(value: CMTimeValue(endTime), timescale: 1000)
        )
    }
}
