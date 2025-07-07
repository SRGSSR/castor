//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

/// A view that displays a Cast icon reflecting the current connection state.
public struct CastIcon: View {
    @ObservedObject var cast: Cast

    // swiftlint:disable:next missing_docs
    public var body: some View {
        switch cast.connectionState {
        case .connecting:
            if #available(iOS 17, *) {
                castImage(name: "google.cast")
                    .symbolEffect(.variableColor.iterative.reversing)
            }
            else {
                castImage(name: "google.cast.fill")
                    .symbolRenderingMode(.multicolor)
            }
        case .connected:
            castImage(name: "google.cast.fill")
        default:
            castImage(name: "google.cast")
        }
    }

    /// Creates a Cast icon.
    public init(cast: Cast) {
        self.cast = cast
    }

    private func castImage(name: String) -> some View {
        Image(name, bundle: .module)
            .resizable()
            .aspectRatio(contentMode: .fit)
    }
}
