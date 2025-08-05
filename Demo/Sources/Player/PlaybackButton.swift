//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

struct PlaybackButton: View {
    let shouldPlay: Bool
    let action: () -> Void

    var body: some View {
        Button {
            action()
        } label: {
            Image(systemName: shouldPlay ? "pause.fill" : "play.fill")
        }
        .font(.system(size: 44))
    }

    init(shouldPlay: Bool, perform action: @escaping () -> Void) {
        self.shouldPlay = shouldPlay
        self.action = action
    }
}
