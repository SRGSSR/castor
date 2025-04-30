//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import CoreMedia

public extension CMTimeRange {
    /// Returns a Boolean value that indicates whether the time range is valid and not empty.
    var isValidAndNotEmpty: Bool {
        isValid && !isEmpty
    }
}
