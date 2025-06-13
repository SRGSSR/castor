//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import GoogleCast
import SwiftUI

/// A mini media controls view.
public struct CastMiniMediaControlsView: UIViewControllerRepresentable {
    // swiftlint:disable:next missing_docs
    public init() {}

    // swiftlint:disable:next missing_docs
    public func makeUIViewController(context: Context) -> GCKUIMiniMediaControlsViewController {
        GCKCastContext.sharedInstance().createMiniMediaControlsViewController()
    }

    // swiftlint:disable:next missing_docs
    public func updateUIViewController(_ uiViewController: GCKUIMiniMediaControlsViewController, context: Context) {}
}
