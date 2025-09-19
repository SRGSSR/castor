//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

struct PlaylistButton: View {
    @Binding var isPlaylistPresented: Bool

    var body: some View {
        Button {
            isPlaylistPresented.toggle()
        } label: {
            Image(systemName: isPlaylistPresented ? "list.bullet.circle.fill" : "list.bullet.circle")
        }
        .accessibilityLabel(accessibilityLabel)
    }
}

private extension PlaylistButton {
    var accessibilityLabel: String {
        if isPlaylistPresented {
            String(localized: "Hide playlist", bundle: .module, comment: "Playlist button accessibility label")
        }
        else {
            String(localized: "Show playlist", bundle: .module, comment: "Playlist button accessibility label")
        }
    }
}
