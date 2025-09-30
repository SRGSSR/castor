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

extension View {
    /// Prevents touch propagation to views located below the receiver.
    func preventsTouchPropagation() -> some View {
        background(.white.opacity(0.0001))
    }

    func pulseSymbolEffect17() -> some View {
        modifier(PulseSymbolEffect17())
    }

    func geometryGroup17() -> some View {
        modifier(GeometryGroup17())
    }
}
