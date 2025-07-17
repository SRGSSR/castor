//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

/// A view that displays a mute icon reflecting the current volume state.
///
/// > Warning: Resize using ``font(_:)``
public struct VolumeIcon: View {
    @ObservedObject var cast: Cast

    private var minimumValueImageName: String {
        let volume = cast.volume
        if cast.isMuted || volume == 0 {
            return "speaker.slash.fill"
        }
        else {
            return "speaker.wave.\(Int(ceilf(volume * 3))).fill"
        }
    }

    // swiftlint:disable:next missing_docs
    public var body: some View {
        ZStack {
            largestShape()
            Image(systemName: minimumValueImageName)
        }
    }

    /// Creates a mute icon.
    public init(cast: Cast) {
        self.cast = cast
    }

    private func largestShape() -> some View {
        // https://stackoverflow.com/questions/78766259/sf-symbol-replace-animation-size-is-off
        ZStack {
            Image(systemName: "speaker.slash.fill")
            Image(systemName: "speaker.wave.3.fill")
        }
        .hidden()
    }
}
