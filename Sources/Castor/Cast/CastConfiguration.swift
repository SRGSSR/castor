//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

/// A cast configuration.
///
/// The configuration controls behaviors set at cast object creation time and that cannot be changed afterwards.
public struct CastConfiguration {
    /// The navigation mode.
    public let navigationMode: CastNavigationMode

    /// The forward skip interval in seconds.
    public let forwardSkipInterval: TimeInterval

    /// The backward skip interval in seconds.
    public let backwardSkipInterval: TimeInterval

    /// Creates a player configuration.
    public init(
        navigationMode: CastNavigationMode = .smart(interval: 3),
        backwardSkipInterval: TimeInterval = 10,
        forwardSkipInterval: TimeInterval = 10
    ) {
        assert(backwardSkipInterval > 0)
        assert(forwardSkipInterval > 0)
        self.navigationMode = navigationMode
        self.backwardSkipInterval = backwardSkipInterval
        self.forwardSkipInterval = forwardSkipInterval
    }

    /// The skip interval for some direction, in seconds.
    public func interval(forSkip skip: CastSkip) -> TimeInterval {
        switch skip {
        case .backward:
            return backwardSkipInterval
        case .forward:
            return forwardSkipInterval
        }
    }
}
