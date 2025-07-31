//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

/// A protocol describing a castable context.
public protocol Castable: AnyObject {
    /// Called when the cast session is established.
    func castStartSession() -> CastResumeState?

    /// Called when the cast session is being stopped.
    ///
    /// - Parameter state: The state right before the cast session ends.
    func castEndSession(with state: CastResumeState?)
}
