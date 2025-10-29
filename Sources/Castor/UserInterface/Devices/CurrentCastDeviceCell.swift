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
        VStack(spacing: 20) {
            Label {
                descriptionView()
            } icon: {
                CastIcon(cast: cast)
            }
            CastVolumeSlider(deviceManager: cast.deviceManager())
            disconnectButton()
        }
    }

    private func descriptionView() -> some View {
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

    private func disconnectButton() -> some View {
        Button(action: cast.endSession) {
            Text("Disconnect", bundle: .module, comment: "Label of the button to disconnect from a Cast receiver")
        }
        // Trick to avoid tapping on the entire cell.
        .buttonStyle(.borderless)
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
