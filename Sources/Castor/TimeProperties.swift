//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import CoreMedia

struct TimeProperties {
    static let empty = Self(time: .invalid, timeRange: .invalid)

    let time: CMTime
    let timeRange: CMTimeRange
}
