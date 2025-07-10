//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Castor
import SwiftUI

private struct PulseSymbolEffect17: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 17.0, *) {
            content
                .symbolEffect(.pulse)
        }
        else {
            content
        }
    }
}

extension View {
    func pulseSymbolEffect17() -> some View {
        modifier(PulseSymbolEffect17())
    }

    @ViewBuilder
    func toolbarBackgroundVisibilityForTabBar18(_ visibility: Visibility) -> some View {
        if #available(iOS 18.0, *) {
            toolbarBackgroundVisibility(visibility, for: .tabBar)
        }
        else {
            self
        }
    }

    func redacted(_ condition: Bool) -> some View {
        redacted(reason: condition ? .placeholder : .init())
    }
}

extension View {
    @ViewBuilder
    func tabViewBottomAccessoryMiniPlayer26(for cast: Cast, in namespace: Namespace.ID) -> some View {
#if swift(>=6.2)
        if #available(iOS 26, *) {
            tabViewBottomAccessory {
                MiniPlayerView(cast: cast)
                    .matchedTransitionSource(id: TransitionId.zoom, in: namespace)
            }
            .tabBarMinimizeBehavior(.onScrollDown)
        }
        else {
            self
        }
#else
        self
#endif
    }

    @ViewBuilder
    func safeAreaInsetMiniPlayer(for cast: Cast, in namespace: Namespace.ID) -> some View {
        if #unavailable(iOS 26) {
            safeAreaInset(edge: .bottom, spacing: 0) {
                if cast.player != nil {
                    MiniPlayerView(cast: cast)
                        .matchedTransitionSource18(id: TransitionId.zoom, in: namespace)
                        .background(.thickMaterial)
                        .frame(height: 64)
                }
            }
            .toolbarBackgroundVisibilityForTabBar18(cast.player == nil ? .automatic : .hidden)
        }
        else {
            self
        }
    }
}

extension View {
    @ViewBuilder
    func matchedTransitionSource18(id: some Hashable, in namespace: Namespace.ID) -> some View {
        if #available(iOS 18, *) {
            matchedTransitionSource(id: id, in: namespace)
        }
        else {
            self
        }
    }

    @ViewBuilder
    func zoomNavigationTransition18(sourceID: some Hashable, in namespace: Namespace.ID) -> some View {
        if #available(iOS 18, *) {
            navigationTransition(.zoom(sourceID: sourceID, in: namespace))
        }
        else {
            self
        }
    }
}
