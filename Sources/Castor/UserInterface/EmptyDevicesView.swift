//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

struct EmptyDevicesView: View {
    var body: some View {
        UnavailableView {
            Label {
                Text("No devices available", comment: "Message displayed when no Cast devices are available")
            } icon: {
                Image(systemName: imageName)
            }
        } description: {
            Text("Check your Wi-Fi network and make sure Local Network Access is on.", comment: "Action suggested when no Cast receivers are found")
        }
    }

    private var imageName: String {
        if #available(iOS 17.0, *) {
            return "tv.badge.wifi.fill"
        }
        else {
            return "tv.fill"
        }
    }
}

#Preview {
    EmptyDevicesView()
}
