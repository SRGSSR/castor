//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

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
