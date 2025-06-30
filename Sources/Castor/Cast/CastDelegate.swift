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
    /// - Parameters:
    ///   - player: The cast player.
    ///   - currentIndex: The index of the current item.
    ///   - assets: The list of the asset from the current asset to the end of the queue.
    func castEndSession(with state: CastResumeState)

    /// Provide an asset based on the information.
    ///
    /// - Parameter information: The media information useful to create an asset.
    func castAsset(from information: CastMediaInformation) -> CastAsset?
}
