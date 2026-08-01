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
    let color: Color

    var body: some View {
        ZStack {
            if cast.devices.isEmpty {
                EmptyDevicesView(color: color)
            }
            else {
                devicesList()
            }
        }
        .animation(.default, value: cast.devices)
        .animation(.default, value: cast.multizoneDevices)
        .navigationTitle(Text("Cast to", bundle: .module, comment: "Cast device selection view title"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading, content: closeButton)
        }
    }

    private func devicesList() -> some View {
        List {
            currentDeviceSection()
            multizoneDevicesSection()
            availableDevicesSection()
        }
        .animation(.default, value: cast.currentDevice)
    }

    @ViewBuilder
    private func currentDeviceSection() -> some View {
        if let currentDevice = cast.currentDevice {
            Section {
                CurrentCastDeviceCell(device: currentDevice, cast: cast, color: color)
            } header: {
                Text("Current device", bundle: .module, comment: "Header for displaying current device information")
            }
        }
    }

    @ViewBuilder
    private func multizoneDevicesSection() -> some View {
        let devices = cast.multizoneDevices
        if !devices.isEmpty {
            Section {
                ForEach(devices) { device in
                    MultizoneDeviceCell(device: device, cast: cast, color: color)
                }
            } header: {
                Text("Paired devices", bundle: .module, comment: "Header for the paired devices list section")
            }
        }
    }

    @ViewBuilder
    private func availableDevicesSection() -> some View {
        let devices = cast.devices.filter { $0 != cast.currentDevice }
        if !devices.isEmpty {
            Section {
                ForEach(devices) { device in
                    CastDeviceCell(device: device, cast: cast, color: color)
                }
            } header: {
                Text("Available devices", bundle: .module, comment: "Header for available devices list section")
            }
        }
    }

    @ViewBuilder
    private func closeButton() -> some View {
        if #available(iOS 26.0, *) {
            Button(role: .close, action: dismiss.callAsFunction)
        }
        else {
            Button(action: dismiss.callAsFunction) {
                Text("Close", bundle: .module, comment: "Close button")
            }
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
