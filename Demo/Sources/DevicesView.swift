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
            ToolbarItem(placement: .topBarLeading) {
                Image(.logo)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
            ToolbarItem {
                if castDeviceManager.connectionState != .disconnected {
                    Button {
                        castDeviceManager.endSession()
                    } label: {
                        Text("Disconnect")
                    }
                }
            }
        }
    }

    private func devicesView() -> some View {
        List(castDeviceManager.devices, id: \.self, selection: castDeviceManager.device(stopCasting: true)) { device in
            HStack {
                VStack(alignment: .leading) {
                    Text(device.friendlyName ?? "Unknown")
                        .fontWeight(castDeviceManager.device == device ? .black : .regular)
                    if let status = device.statusText, !status.isEmpty {
                        Text(status)
                            .font(.footnote)
                    }
                }
                if castDeviceManager.device == device {
                    Spacer()
                    switch castDeviceManager.connectionState {
                    case .connecting:
                        ProgressView()
                    case .connected:
                        Image(systemName: "checkmark")
                    default:
                        EmptyView()
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
