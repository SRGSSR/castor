//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import GoogleCast
import SwiftUI

/// A cast button.
public struct CastButton: UIViewRepresentable {
    // swiftlint:disable:next missing_docs
    public init() {}

    // swiftlint:disable:next missing_docs
    public func makeUIView(context: Context) -> UIView {
        GCKUICastButton()
    }

    // swiftlint:disable:next missing_docs
    public func updateUIView(_ uiView: UIView, context: Context) {}
}
