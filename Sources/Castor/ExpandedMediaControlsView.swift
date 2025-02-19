//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import GoogleCast
import SwiftUI

private struct _ExpandedMediaControlsView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> GCKUIExpandedMediaControlsViewController {
        GCKCastContext.sharedInstance().defaultExpandedMediaControlsViewController
    }

    func updateUIViewController(_ uiViewController: GCKUIExpandedMediaControlsViewController, context: Context) {}
}

/// An expanded media controls view.
public struct ExpandedMediaControlsView: View {
    // swiftlint:disable:next missing_docs
    public var body: some View {
        _ExpandedMediaControlsView()
            .ignoresSafeArea()
    }

    // swiftlint:disable:next missing_docs
    public init() {}
}
