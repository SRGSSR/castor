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
    @State private var isPresented = false
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    // swiftlint:disable:next missing_docs
    public var body: some View {
        Button {
            isPresented = true
        } label: {
            CastIcon(cast: cast)
        }
        .popover(isPresented: $isPresented) {
            NavigationStack {
                CastDevicesView(cast: cast, showsCloseButton: horizontalSizeClass == .compact)
            }
            .frame(minWidth: 375, minHeight: 500)
        }
    }

    /// Default initializer.
    public init(cast: Cast) {
        self.cast = cast
    }
}
