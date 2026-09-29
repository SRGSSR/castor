//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import CoreMedia

struct Chapter: Decodable {
    let identifier: String
    let title: String
    let posterUrl: URL
    let startTime: Double
    let endTime: Double

    var timeRange: CMTimeRange {
        .init(
            start: .init(value: CMTimeValue(startTime), timescale: 1000),
            end: .init(value: CMTimeValue(endTime), timescale: 1000)
        )
    }
}
