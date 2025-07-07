//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

struct EmptyDevicesView: View {
    var body: some View {
        UnavailableView(
            "No devices available",
            systemImage: "tv.badge.wifi.fill",
            description: Text("Check your Wi-Fi network and make sure Local Network Access is on.")
        )
    }
}

#Preview {
    EmptyDevicesView()
}
