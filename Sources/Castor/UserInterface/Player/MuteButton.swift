//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

/// A mute button.
public struct MuteButton: View {
    @ObservedObject var cast: Cast

    // swiftlint:disable:next missing_docs
    public var body: some View {
        Button {
            cast.isMuted.toggle()
        } label: {
            MuteIcon(cast: cast)
        }
        .disabled(!cast.canMute)
    }

    /// Creates a mute button.
    public init(cast: Cast) {
        self.cast = cast
    }
}
