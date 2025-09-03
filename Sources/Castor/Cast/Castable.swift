//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

/// A protocol that defines a castable context.
public protocol Castable: AnyObject {
    /// Invoked when a Cast session has been established.
    ///
    /// - Returns: The current state.
    func castStartSession() -> CastResumeState?

    /// Invoked when the Cast session is about to stop.
    ///
    /// - Parameter state: The state immediately before the Cast session ends.
    func castEndSession(with state: CastResumeState?)
}
