//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Castor
import SwiftUI

private struct NoDevicesView: View {
    var body: some View {
        ContentUnavailableView {
            Label("No devices available", systemImage: "tv.badge.wifi.fill")
        } description: {
            Text("Check your Wi-Fi network and make sure Local Network Access is on.")
        }
    }
}

struct DevicesView: View {
    @StateObject private var castDeviceManager = CastDeviceManager()

    var body: some View {
        ZStack {
            if castDeviceManager.devices.isEmpty {
                NoDevicesView()
            }
            else {
                devicesView()
            }
        }
        .animation(.default, value: castDeviceManager.devices)
        .navigationTitle("Devices")
    }

    private func devicesView() -> some View {
        List(castDeviceManager.devices, id: \.deviceID) { device in
            VStack(alignment: .leading) {
                Text(device.friendlyName ?? "Unknown")
                if let status = device.statusText, !status.isEmpty {
                    Text(status)
                        .font(.footnote)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        DevicesView()
    }
}

#Preview("NoDevicesView") {
    NoDevicesView()
}
