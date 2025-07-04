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

    private var minimumValueImageName: String {
        cast.volume == 0 ? "speaker.slash.fill" : "speaker.wave.1.fill"
    }

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
        .navigationTitle("Cast to")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading, content: closeButton)
        }
        .onChange(of: cast.currentDevice) { _ in
            dismiss()
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

    private func devicesList() -> some View {
        List {
            if let currentDevice = cast.currentDevice {
                Section {
                    currentDeviceCell(with: currentDevice)
                } header: {
                    Text("Current device")
                }
            }
            Section {
                ForEach(availableDevices(), id: \.self) { device in
                    cell(for: device)
                }
            } header: {
                Text("Available devices")
            }
        }
    }

    private func currentDeviceCell(with device: CastDevice) -> some View {
        VStack {
            HStack {
                Label {
                    descriptionView(for: device)
                } icon: {
                    Image(systemName: Self.imageName(for: device))
                }
                Button(action: cast.endSession) {
                    Text("Disconnect")
                }
            }
            volumeSlider()
        }
    }

    private func cell(for device: CastDevice) -> some View {
        Button {
            cast.currentDevice = device
        } label: {
            Label {
                descriptionView(for: device)
            } icon: {
                Image(systemName: Self.imageName(for: device))
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private func availableDevices() -> [CastDevice] {
        cast.devices.filter { $0 != cast.currentDevice }
    }

    private func volumeSlider() -> some View {
        Slider(value: $cast.volume, in: cast.volumeRange) {
            Text("Volume")
        } minimumValueLabel: {
            Image(systemName: minimumValueImageName)
        } maximumValueLabel: {
            Image(systemName: "speaker.wave.3.fill")
        }
        .disabled(!cast.canAdjustVolume)
    }

    private func closeButton() -> some View {
        Button {
            dismiss()
        } label: {
            Text("Close")
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
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
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
