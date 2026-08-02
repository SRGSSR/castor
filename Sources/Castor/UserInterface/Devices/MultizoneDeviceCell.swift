//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

struct MultizoneDeviceCell: View {
    let device: CastMultizoneDevice
    let cast: Cast
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            descriptionView()
            CastVolumeSlider(deviceManager: cast.deviceManager(forMultizoneDevice: device))
                .tint(color)
        }
    }

    private func descriptionView() -> some View {
        Text(CastMultizoneDevice.name(for: device))
            .lineLimit(1)
    }
}
