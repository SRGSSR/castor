//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

/// An icon reflecting the current volume.
///
/// > Warning: Adjust the icon size using ``font(_:)``
public struct CastVolumeIcon: View {
    @ObservedObject var deviceManager: CastDeviceManager

    private var minimumValueImageName: String {
        let volume = deviceManager.volume
        if deviceManager.isMuted || volume == 0 {
            return "speaker.slash.fill"
        }
        else {
            return "speaker.wave.\(Int(ceilf(volume * 3))).fill"
        }
    }

    // swiftlint:disable:next missing_docs
    public var body: some View {
        ZStack {
            largestShape()
            Image(systemName: minimumValueImageName)
        }
    }

    /// Creates a volume icon.
    public init(deviceManager: CastDeviceManager) {
        self.deviceManager = deviceManager
    }

    private func largestShape() -> some View {
        // https://stackoverflow.com/questions/78766259/sf-symbol-replace-animation-size-is-off
        ZStack {
            Image(systemName: "speaker.slash.fill")
            Image(systemName: "speaker.wave.3.fill")
        }
        .hidden()
    }
}
