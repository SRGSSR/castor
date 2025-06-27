//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

/// Methods for managing cast session.
public protocol CastDelegate: AnyObject {
    /// Called when the cast session is established.
    /// - Parameters:
    ///   - cast: The cast object.
    ///   - player: The cast player.
    func cast(_ cast: Cast, startSessionWithState state: CastResumeState?)

    /// Called when the cast session is being stopped.
    /// - Parameters:
    ///   - cast: The cast object.
    ///   - player: The cast player.
    ///   - currentIndex: The index of the current item.
    ///   - assets: The list of the asset from the current asset to the end of the queue.
    func cast(_ cast: Cast, endSessionWithState state: CastResumeState?)
}
