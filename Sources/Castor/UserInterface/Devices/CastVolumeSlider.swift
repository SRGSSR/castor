//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

/// A slider that controls the volume an active Cast device.
public struct CastVolumeSlider: View {
    @ObservedObject var deviceManager: CastDeviceManager

    private var volume: Binding<Float> {
        .init {
            deviceManager.isMuted ? 0 : deviceManager.volume
        } set: { newValue in
            deviceManager.volume = newValue
        }
    }

    // swiftlint:disable:next missing_docs
    public var body: some View {
        Slider(value: volume, in: deviceManager.volumeRange) {
            Text("Volume", bundle: .module, comment: "Volume slider label")
        } minimumValueLabel: {
            CastMuteButton(deviceManager: deviceManager)
                // Trick to avoid tapping on the entire cell.
                .buttonStyle(.borderless)
                .toAnyView()
        } maximumValueLabel: {
            EmptyView()
                .toAnyView()
        }
        .disabled(!deviceManager.canAdjustVolume)
    }

    /// Creates a slider.
    public init(deviceManager: CastDeviceManager) {
        self.deviceManager = deviceManager
    }
}
