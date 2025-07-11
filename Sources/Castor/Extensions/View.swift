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
    /// Supports casting with the provided delegate.
    ///
    /// - Parameters:
    ///   - cast: The cast object.
    ///   - delegate: The delegate.
    func supportsCast(_ cast: Cast, with delegate: CastDelegate) -> some View {
        onAppear {
            cast.delegate = delegate
        }
    }

    /// Makes a view context castable.
    ///
    /// - Parameters:
    ///   - castable: The object that can be cast.
    ///   - cast: The cast object.
    func makeCastable(_ castable: Castable, with cast: Cast) -> some View {
        onAppear {
            cast.castable = castable
        }
    }
}

extension View {
    func toAnyView() -> AnyView {
        AnyView(self)
    }

    func redacted(_ condition: Bool) -> some View {
        redacted(reason: condition ? .placeholder : .init())
    }
}
