//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

struct MuteIcon: View {
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

    var body: some View {
        ZStack {
            largestShape()
            Image(systemName: minimumValueImageName)
        }
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
