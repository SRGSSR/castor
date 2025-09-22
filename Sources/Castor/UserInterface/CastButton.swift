//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import GoogleCast
import SwiftUI

/// A Cast button.
///
/// Displays a receiver selection popover (or modal sheet, depending on available width) and automatically reflects
/// the current connection state.
public struct CastButton: View {
    @ObservedObject var cast: Cast
    @Binding private var isPresenting: Bool

    @State private var isPresented = false

    // swiftlint:disable:next missing_docs
    public var body: some View {
        Button {
            isPresented = true
        } label: {
            CastIcon(cast: cast)
        }
        .accessibilityHint(accessibilityHint)
        .popover(isPresented: $isPresented) {
            NavigationStack {
                CastDevicesView(cast: cast)
                    .font(nil)
                    .foregroundColor(nil)
                    .tint(nil)
            }
            .frame(idealWidth: 375, idealHeight: 500)
        }
        .onChange(of: isPresented) { newValue in
            isPresenting = newValue
        }
    }

    /// Creates a Cast button.
    public init(cast: Cast, isPresenting: Binding<Bool> = .constant(false)) {
        self.cast = cast
        _isPresenting = isPresenting
    }
}

private extension CastButton {
    var accessibilityHint: String {
        switch cast.connectionState {
        case .connected, .connecting:
            String(localized: "Manages the Cast session", bundle: .module, comment: "Accessibility hint associated with the Cast button when connected")
        default:
            String(localized: "Connects to a Cast device", bundle: .module, comment: "Accessibility hint associated with the Cast button when not connected")
        }
    }
}
