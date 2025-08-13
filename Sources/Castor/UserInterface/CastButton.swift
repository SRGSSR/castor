//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import GoogleCast
import SwiftUI

/// A cast button.
public struct CastButton: View {
    @ObservedObject var cast: Cast
    @Binding private var isPresenting: Bool

    @State private var isPresented = false
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    private var showsPopover: Bool {
        UIDevice.current.userInterfaceIdiom == .pad && horizontalSizeClass == .regular
    }

    private var minSize: CGSize {
        showsPopover ? .init(width: 375, height: 500) : .zero
    }

    // swiftlint:disable:next missing_docs
    public var body: some View {
        Button {
            isPresented = true
        } label: {
            CastIcon(cast: cast)
        }
        .popover(isPresented: $isPresented) {
            NavigationStack {
                CastDevicesView(cast: cast, showsCloseButton: !showsPopover)
                    .font(nil)
                    .foregroundColor(nil)
                    .tint(nil)
            }
            .frame(minWidth: minSize.width, minHeight: minSize.height)
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
