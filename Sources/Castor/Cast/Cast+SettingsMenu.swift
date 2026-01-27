//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

private struct DeviceCell: View {
    let device: CastDevice

    var body: some View {
        Label {
            Text(device.name ?? "Unnamed receiver")
        } icon: {
            Image(systemName: CastDevice.imageName(for: device))
        }
    }
}

private struct DeviceMenuContent: View {
    let action: (CastDevice?) -> Void

    @EnvironmentObject var cast: Cast

    var body: some View {
        Picker("Devices", selection: selection) {
            ForEach(cast.devices, id: \.self) { device in
                DeviceCell(device: device)
                    .tag(device)
            }
        }
        .pickerStyle(.inline)

        if cast.currentDevice != nil {
            Button(role: .destructive) {
                cast.endSession()
                action(nil)
            } label: {
                Text("Disconnect")
            }
        }
    }

    private var selection: Binding<CastDevice?> {
        .init {
            cast.currentDevice
        } set: { newValue in
            cast.currentDevice = newValue
            action(newValue)
        }
    }
}

public extension Cast {
    /// Returns content for a playback speed menu.
    ///
    /// - Parameters:
    ///    - speeds: The offered playback speeds.
    ///    - action: The action to perform when the user interacts with an item from the menu.
    ///
    /// The returned view is meant to be used as content of a `Menu`. Using it for any other purpose has undefined
    /// behavior.
    func deviceMenu(action: @escaping (_ device: CastDevice?) -> Void = { _ in }) -> some View {
        DeviceMenuContent(action: action)
    }
}
