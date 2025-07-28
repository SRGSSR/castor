//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

/// Methods for managing a cast session.
public protocol CastDelegate: AnyObject {
    /// Called when the cast session is established.
    func castStartSession()

    /// Called when the cast session is being stopped.
    /// 
    /// - Parameter state: The state right before the cast session ends.
    func castEndSession(with state: CastResumeState?)
}
