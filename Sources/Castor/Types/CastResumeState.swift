//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import CoreMedia

/// State information useful when transitioning between remote and local playback.
public struct CastResumeState {
    /// The assets.
    public let assets: [CastAsset]

    /// The current index.
    public let index: Int

    /// The current time.
    ///
    /// An `.invalid` time corresponds to the default playback position.
    public let time: CMTime

    /// Creates a state.
    /// 
    /// - Parameters:
    ///   - assets: The assets.
    ///   - index: The current index.
    ///   - time: The current time. Use `.invalid` for the default playback position.
    ///
    /// Fails if no valid index into the asset list is provided.
    public init?(assets: [CastAsset], index: Int?, time: CMTime) {
        guard let index, assets.indices.contains(index) else { return nil }
        self.assets = assets
        self.index = index
        self.time = time
    }
}
