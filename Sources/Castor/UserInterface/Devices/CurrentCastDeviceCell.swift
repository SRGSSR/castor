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
            volumeSlider()
            disconnectButton()
        }
    }

    private var status: String {
        if let status = device.status {
            return status
        }
        else {
            return String(localized: "Not playing", bundle: .module, comment: "Label displayed when no content is being played")
        }
    }

    private func descriptionView() -> some View {
        VStack(alignment: .leading) {
            HStack {
                Text(deviceName)
                    .lineLimit(1)
            }
            Text(status)
                .font(.footnote)
                .foregroundStyle(.secondary)
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

    @ViewBuilder
    private func volumeSlider() -> some View {
        if let deviceManager = cast.deviceManager(for: device) {
            CastVolumeSlider(deviceManager: deviceManager)
        }
        else {
            volumeSliderPlaceholder()
        }
    }

    private func volumeSliderPlaceholder() -> some View {
        Slider(value: .constant(0)) {
            Text("Volume", bundle: .module, comment: "Volume slider label")
        } minimumValueLabel: {
            // https://stackoverflow.com/questions/78766259/sf-symbol-replace-animation-size-is-off
            ZStack {
                Image(systemName: "speaker.slash.fill")
                Image(systemName: "speaker.wave.3.fill")
                    .hidden()
            }
            .toAnyView()
        } maximumValueLabel: {
            EmptyView()
                .toAnyView()
        }
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
