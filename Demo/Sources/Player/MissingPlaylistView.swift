//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

struct MissingPlaylistView: View {
    var body: some View {
        UnavailableView {
            Label {
                Text("No playlist")
            } icon: {
                Image(systemName: "list.bullet")
            }
        }
        .background(Color(uiColor: .systemGroupedBackground))
    }
}
