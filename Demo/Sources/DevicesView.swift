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

    private static func imageName(for device: GCKDevice) -> String {
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
        List(castDeviceManager.devices, id: \.self, selection: castDeviceManager.device()) { device in
            HStack {
                Image(systemName: Self.imageName(for: device))
                VStack(alignment: .leading) {
                    Text(device.friendlyName ?? "Unknown")
                    if let status = device.statusText, !status.isEmpty {
                        Text(status)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
                if castDeviceManager.device == device {
                    Spacer()
                    switch castDeviceManager.connectionState {
                    case .connecting:
                        ProgressView()
                    case .connected:
                        Image(systemName: "wifi")
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
