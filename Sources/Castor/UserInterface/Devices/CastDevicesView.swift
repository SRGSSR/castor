//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import GoogleCast
import SwiftUI

struct CastDevicesView: View {
    @ObservedObject var cast: Cast
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            if cast.devices.isEmpty {
                EmptyDevicesView()
            }
            else {
                devicesList()
            }
        }
        .animation(.default, value: cast.devices)
        .navigationTitle(Text("Cast to", bundle: .module, comment: "Cast device selection view title"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading, content: closeButton)
        }
    }

    private func devicesList() -> some View {
        List {
            currentDeviceSection()
            availableDevicesSection()
        }
        .animation(.default, value: cast.currentDevice)
    }

    @ViewBuilder
    private func currentDeviceSection() -> some View {
        if let currentDevice = cast.currentDevice {
            Section {
                CurrentCastDeviceCell(device: currentDevice, cast: cast)
            } header: {
                Text("Current device", bundle: .module, comment: "Header for displaying current device information")
            }
        }
    }

    @ViewBuilder
    private func availableDevicesSection() -> some View {
        let devices = cast.devices.filter { $0 != cast.currentDevice }
        if !devices.isEmpty {
            Section {
                ForEach(devices, id: \.self) { device in
                    CastDeviceCell(device: device, cast: cast)
                }
            } header: {
                Text("Available devices", bundle: .module, comment: "Header for available devices list section")
            }
        }
    }

    private func closeButton() -> some View {
        Button {
            dismiss()
        } label: {
            Text("Close", bundle: .module, comment: "Close button")
        }
    }

    @ViewBuilder
    private func statusView() -> some View {
        switch cast.connectionState {
        case .connecting:
            ProgressView()
                .accessibilityHidden(true)
        case .connected:
            Image(systemName: "wifi")
        default:
            EmptyView()
        }
    }
}
