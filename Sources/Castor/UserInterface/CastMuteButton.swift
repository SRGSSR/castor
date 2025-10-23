//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

/// A mute button.
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
    public init(deviceManager: CastDeviceManager) {
        self.deviceManager = deviceManager
    }
}

private extension CastMuteButton {
    var accessibilityLabel: String {
        if deviceManager.isMuted {
            String(localized: "Muted", bundle: .module, comment: "Accessibility label for muted state")
        }
        else {
            String(localized: "Unmuted", bundle: .module, comment: "Accessibility label for unmuted state")
        }
    }

    private var deviceName: String {
        // TODO:
        ""
    }
}
