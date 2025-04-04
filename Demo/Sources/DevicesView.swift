//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Castor
import GoogleCast
import SwiftUI

private struct NoDevicesView: View {
    var body: some View {
        MessageView(
            message: "No devices available",
            icon: .system("tv.badge.wifi.fill"),
            description: "Check your Wi-Fi network and make sure Local Network Access is on."
        )
    }
}

struct DevicesView: View {
    @EnvironmentObject private var cast: Cast

    var body: some View {
        ZStack {
            if cast.devices.isEmpty {
                NoDevicesView()
            }
            else {
                devicesView()
            }
        }
        .animation(.default, value: cast.devices)
        .navigationTitle("Devices")
        .toolbar {
            ToolbarItem(content: disconnectButton)
        }
    }

    private static func imageName(for device: CastDevice) -> String {
        switch device.type {
        case .TV:
            "tv"
        case .speaker:
            "hifispeaker"
        case .speakerGroup:
            "hifispeaker.2"
        default:
            "tv.and.hifispeaker.fill"
        }
    }

    private func devicesView() -> some View {
        List(cast.devices, id: \.self, selection: $cast.currentDevice) { device in
            HStack {
                Image(systemName: Self.imageName(for: device))
                descriptionView(for: device)
                if cast.isCasting(on: device) {
                    Spacer()
                    statusView()
                }
            }
        }
    }

    @ViewBuilder
    private func disconnectButton() -> some View {
        if cast.connectionState != .disconnected {
            Button {
                cast.endSession()
            } label: {
                Text("Disconnect")
            }
        }
    }

    private func descriptionView(for device: CastDevice) -> some View {
        VStack(alignment: .leading) {
            Text(device.name ?? "Unknown")
            if let status = device.status {
                Text(status)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
    }

    @ViewBuilder
    private func statusView() -> some View {
        switch cast.connectionState {
        case .connecting:
            ProgressView()
        case .connected:
            Image(systemName: "wifi")
        default:
            EmptyView()
        }
    }
}

#Preview {
    NavigationStack {
        DevicesView()
    }
    .environmentObject(Cast())
}

#Preview("NoDevicesView") {
    NoDevicesView()
}
