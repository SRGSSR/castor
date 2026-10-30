//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

/// A Cast configuration.
///
/// The configuration defines the behavior of a ``Cast`` object. Update ``Cast/configuration`` to change it.
public struct CastConfiguration {
    /// The navigation mode.
    public var navigationMode: CastNavigationMode

    /// The backward skip interval in seconds.
    ///
    /// Must be greater than zero.
    public var backwardSkipInterval: TimeInterval {
        didSet {
            assert(backwardSkipInterval > 0)
        }
    }

    /// The forward skip interval in seconds.
    ///
    /// Must be greater than zero.
    public var forwardSkipInterval: TimeInterval {
        didSet {
            assert(forwardSkipInterval > 0)
        }
    }

    /// Creates a configuration.
    ///
    /// - Parameters:
    ///   - navigationMode: The navigation mode.
    ///   - backwardSkipInterval: The backward skip interval in seconds. Must be greater than zero.
    ///   - forwardSkipInterval: The forward skip interval in seconds. Must be greater than zero.
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

    /// Returns the skip interval, in seconds, for a given direction.
    ///
    /// - Parameter skip: The skip direction.
    /// - Returns: The skip interval in seconds.
    public func interval(forSkip skip: CastSkip) -> TimeInterval {
        switch skip {
        case .backward:
            return backwardSkipInterval
        case .forward:
            return forwardSkipInterval
        }
    }
}
