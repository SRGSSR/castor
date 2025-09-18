//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

struct CastDeviceCell: View {
    let device: CastDevice
    let cast: Cast

    var body: some View {
        Button {
            cast.currentDevice = device
        } label: {
            Label {
                descriptionView(for: device)
            } icon: {
                Image(systemName: Self.imageName(for: device))
            }
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
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

    private func descriptionView(for device: CastDevice) -> some View {
        Text(device.name ?? "Unknown")
            .lineLimit(1)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }
}
