//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Castor
import SwiftUI

struct DevicesView: View {
    @StateObject private var castDeviceManager = CastDeviceManager()

    var body: some View {
        List(castDeviceManager.devices, id: \.deviceID) { device in
            VStack(alignment: .leading) {
                Text(device.friendlyName ?? "Unknown")
                if let status = device.statusText, !status.isEmpty {
                    Text(status)
                        .font(.footnote)
                }
            }
        }
        .animation(.default, value: castDeviceManager.devices)
        .navigationTitle("Devices")
    }
}

#Preview {
    NavigationStack {
        DevicesView()
    }
}
