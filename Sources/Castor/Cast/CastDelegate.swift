//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

/// A protocol for handling events related to a cast session.
public protocol CastDelegate: AnyObject {
    /// Invoked when a Cast session has been established.
    func castStartSession()

    /// Invoked when the Cast session is about to stop.
    ///
    /// - Parameter state: The state immediately before the Cast session ends.
    func castEndSession(with state: CastResumeState?)
}
