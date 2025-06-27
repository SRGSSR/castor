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
    /// Assigns an object which listens to the cast session lifecycle.
    ///
    /// - Parameters:
    ///   - cast: The cast object.
    ///   - delegate: The object which handle cast session lifecycle.
    func castLifecycle(using delegate: CastDelegate, for cast: Cast) -> some View {
        onAppear {
            cast.delegate = delegate
        }
    }

    /// Assigns an object which provides assets.
    ///
    /// - Parameters:
    ///   - cast: The cast object.
    ///   - dataSource: The object providing assets.
    func castAssets(from dataSource: CastDataSource, for cast: Cast) -> some View {
        onAppear {
            cast.dataSource = dataSource
        }
    }
}
