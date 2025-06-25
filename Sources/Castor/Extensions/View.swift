//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

public extension View {
    /// Binds a progress tracker to a player.
    ///
    /// - Parameters:
    ///   - progressTracker: The progress tracker to bind.
    ///   - player: The player to observe.
    func bind(_ progressTracker: CastProgressTracker, to player: CastPlayer?) -> some View {
        onAppear {
            progressTracker.player = player
        }
        .onChange(of: player) { newValue in
            progressTracker.player = newValue
        }
    }
}

public extension View {
    func enableCastPlaybackSwitching(_ cast: Cast, using delegate: CastDelegate?, and dataSource: CastDataSource? = nil) -> some View {
        onAppear {
            cast.delegate = delegate
            // FIXME: The data source seems to be useless in some cases: When we start a cast session without local player. Should we split this method?
            cast.dataSource = dataSource
        }
    }
}
