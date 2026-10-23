//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

/// A button that mutes or unmutes a Cast device.
public struct CastMuteButton: View {
    @ObservedObject var deviceManager: CastDeviceManager

    // swiftlint:disable:next missing_docs
    public var body: some View {
        Button {
            deviceManager.isMuted.toggle()
        } label: {
            CastVolumeIcon(deviceManager: deviceManager)
        }
        .disabled(!deviceManager.canMute)
        .accessibilityLabel(accessibilityLabel)
    }

    /// Creates a mute button.
    ///
    /// - Parameter deviceManager: The manager of the device to control.
    public init(deviceManager: CastDeviceManager) {
        self.deviceManager = deviceManager
    }
}

private extension CastMuteButton {
    var accessibilityLabel: LocalizedStringResource {
        if deviceManager.isMuted {
            LocalizedStringResource("Muted", bundle: .module, comment: "Accessibility label for muted state")
        }
        else {
            LocalizedStringResource("Unmuted", bundle: .module, comment: "Accessibility label for unmuted state")
        }
    }
}
