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
        .toolbar {
            ToolbarItem {
                Button {
                    castDeviceManager.endSession()
                } label: {
                    Text("Disconnect")
                        .font(.footnote)
                        .fontWeight(.medium)
                }
            }
        }
    }

    private func devicesView() -> some View {
        List(castDeviceManager.devices, id: \.deviceID) { device in
            Button {
                castDeviceManager.startSession(with: device)
            } label: {
                VStack(alignment: .leading) {
                    Text(device.friendlyName ?? "Unknown")
                        .fontWeight(castDeviceManager.device == device ? .black : .regular)
                    if let status = device.statusText, !status.isEmpty {
                        Text(status)
                            .font(.footnote)
                    }
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
