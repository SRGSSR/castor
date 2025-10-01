//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

private struct GeometryGroup17: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 17.0, *) {
            content
                .geometryGroup()
        }
        else {
            content
        }
    }
}

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
    /// Enables casting with the specified delegate.
    ///
    /// - Parameters:
    ///   - cast: The Cast object.
    ///   - delegate: The delegate to handle Cast events.
    func supportsCast(_ cast: Cast, with delegate: CastDelegate) -> some View {
        onAppear {
            cast.delegate = delegate
        }
    }

    /// Makes a view context castable.
    ///
    /// - Parameters:
    ///   - castable: The view context that can be cast.
    ///   - cast: The Cast object.
    func castable(_ castable: Castable, with cast: Cast) -> some View {
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

    func geometryGroup17() -> some View {
        modifier(GeometryGroup17())
    }
}
