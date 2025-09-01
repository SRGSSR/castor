//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

/// A Cast configuration.
///
/// The configuration defines behaviors set when the ``Cast`` object is created and cannot be changed afterwards.
public struct CastConfiguration {
    /// The navigation mode.
    public let navigationMode: CastNavigationMode

    /// The forward skip interval in seconds.
    public let forwardSkipInterval: TimeInterval

    /// The backward skip interval in seconds.
    public let backwardSkipInterval: TimeInterval

    /// Creates a configuration.
    ///
    /// - Parameters:
    ///   - navigationMode: The navigation mode.
    ///   - backwardSkipInterval: The forward skip interval in seconds.
    ///   - forwardSkipInterval: The backward skip interval in seconds.
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

    /// The skip interval, in seconds, for a given direction.
    public func interval(forSkip skip: CastSkip) -> TimeInterval {
        switch skip {
        case .backward:
            return backwardSkipInterval
        case .forward:
            return forwardSkipInterval
        }
    }
}
