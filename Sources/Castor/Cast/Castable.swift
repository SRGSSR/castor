//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

/// A protocol that defines a castable context.
public protocol Castable: AnyObject {
    /// Invoked when a Cast session has been established.
    ///
    /// - Returns: The state from which playback should resume on the receiver, or `nil` to load nothing.
    @MainActor
    func castStartSession() -> CastResumeState?

    /// Invoked when the Cast session is about to stop.
    ///
    /// - Parameter state: The state immediately before the Cast session ends.
    @MainActor
    func castEndSession(with state: CastResumeState?)
}
