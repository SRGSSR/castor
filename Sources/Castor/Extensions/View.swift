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
    func enable(_ cast: Cast, using dataSource: CastDataSource?, and delegate: CastDelegate?) -> some View {
        onAppear {
            cast.dataSource = dataSource
            cast.delegate = delegate
        }
    }
}
