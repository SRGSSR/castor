//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import GoogleCast
import SwiftUI

/// A cast button.
public struct CastButton: UIViewRepresentable {
    public init() {}

    public func makeUIView(context: Context) -> UIView {
        GCKUICastButton()
    }

    public func updateUIView(_ uiView: UIView, context: Context) {}
}
