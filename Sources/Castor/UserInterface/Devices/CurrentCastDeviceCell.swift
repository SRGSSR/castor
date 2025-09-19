//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

struct CurrentCastDeviceCell: View {
    let device: CastDevice
    @ObservedObject var cast: Cast

    var body: some View {
        VStack {
            Label {
                descriptionView(for: device)
            } icon: {
                CastIcon(cast: cast)
            }
            volumeSlider()
            disconnectButton()
        }
    }

    private var volume: Binding<Float> {
        .init {
            cast.isMuted ? 0 : cast.volume
        } set: { newValue in
            cast.volume = newValue
        }
    }

    private func descriptionView(for device: CastDevice) -> some View {
        VStack(alignment: .leading) {
            HStack {
                Text(deviceName)
                    .lineLimit(1)
            }
            if let status = device.status {
                Text(status)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .accessibilityElement()
        .accessibilityLabel(accessibilityLabel)
    }

    private func volumeSlider() -> some View {
        Slider(value: volume, in: cast.volumeRange) {
            Text("Volume", bundle: .module, comment: "Volume slider label")
        } minimumValueLabel: {
            CastMuteButton(cast: cast)
                .buttonStyle(.borderless) // Trick to avoid tapping on the entire cell.
                .toAnyView()
        } maximumValueLabel: {
            EmptyView()
                .toAnyView()
        }
        .disabled(!cast.canAdjustVolume)
    }

    private func disconnectButton() -> some View {
        Button(action: cast.endSession) {
            Text("Disconnect", bundle: .module, comment: "Label of the button to disconnect from a Cast receiver")
        }
        .buttonStyle(.borderless) // Trick to avoid tapping on the entire cell.
        .padding(.bottom)
    }
}

private extension CurrentCastDeviceCell {
    var accessibilityLabel: String {
        String(
            localized: "Connected to \(deviceName)",
            bundle: .module,
            comment: "Current device accessibility label when connected to a receiver device (device name as wildcard)"
        )
    }

    private var deviceName: String {
        CastDevice.name(for: cast.currentDevice)
    }
}
