//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import GoogleCast
import SwiftUI

/// A mini media controls view.
public struct MiniMediaControlsView: UIViewControllerRepresentable {
    public init() {}

    public func makeUIViewController(context: Context) -> GCKUIMiniMediaControlsViewController {
        GCKCastContext.sharedInstance().createMiniMediaControlsViewController()
    }

    public func updateUIViewController(_ uiViewController: GCKUIMiniMediaControlsViewController, context: Context) {}
}
