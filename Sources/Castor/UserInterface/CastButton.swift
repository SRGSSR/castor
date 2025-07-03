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

    // swiftlint:disable:next missing_docs
    public var body: some View {
        Button {
            isPresented = true
        } label: {
            castImage()
        }
        .sheet(isPresented: $isPresented) {
            NavigationStack {
                CastDevicesView(cast: cast)
            }
        }
    }

    /// Default initializer.
    public init(cast: Cast) {
        self.cast = cast
    }

    private func castImage(name: String) -> some View {
        Image(name, bundle: .module)
            .resizable()
            .fontWeight(.bold)
            .aspectRatio(contentMode: .fit)
    }

    @ViewBuilder
    private func castImage() -> some View {
        switch cast.connectionState {
        case .connecting:
            castImage(name: "google.cast")
                .symbolEffect()
        case .connected:
            castImage(name: "google.cast.fill")
        default:
            castImage(name: "google.cast")
        }
    }
}

private extension View {
    @ViewBuilder
    func symbolEffect() -> some View {
        if #available(iOS 17, *) {
            symbolEffect(.variableColor.reversing)
        }
        else {
            self
        }
    }
}
