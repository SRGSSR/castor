//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

struct MissingListView: View {
    let title: String

    var body: some View {
        UnavailableView {
            Label {
                Text(title)
            } icon: {
                Image(systemName: "list.bullet")
            }
        }
        .background(Color(uiColor: .systemGroupedBackground))
    }
}
