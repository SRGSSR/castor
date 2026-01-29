//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Castor
import GoogleCast
import SwiftUI

struct DeviceMenu: View {
    @EnvironmentObject private var cast: Cast

    var body: some View {
        Menu {
            cast.deviceMenu()
        } label: {
            Label {
                Text("Cast")
            } icon: {
                CastIcon(cast: cast)
            }
            currentDevice()
        }
    }

    @ViewBuilder
    private func currentDevice() -> some View {
        if let currentDevice = cast.currentDevice {
            Text(currentDevice.name ?? "Untitled")
        }
    }
}
