//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

struct MissingChapterView: View {
    var body: some View {
        UnavailableView {
            Label {
                Text("No chapters")
            } icon: {
                Image(systemName: "list.bullet")
            }
        }
        .background(Color(uiColor: .systemGroupedBackground))
    }
}
