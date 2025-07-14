//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

/// A cast player view.
public struct CastPlayerView: View {
    @ObservedObject private var cast: Cast

    // swiftlint:disable:next missing_docs
    public var body: some View {
        if let player = cast.player {
            ControlsView(player: player, device: cast.currentDevice)
        }
    }

    // swiftlint:disable:next missing_docs
    public init(cast: Cast) {
        self.cast = cast
    }
}
