//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

struct MultizoneDeviceCell: View {
    let device: CastMultizoneDevice
    let cast: Cast

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            descriptionView()
            volumeSlider()
        }
    }

    private func descriptionView() -> some View {
        Text(CastMultizoneDevice.name(for: device))
            .lineLimit(1)
    }

    @ViewBuilder
    private func volumeSlider() -> some View {
        if let deviceManager = cast.deviceManager(for: device) {
            CastVolumeSlider(deviceManager: deviceManager)
        }
    }
}
