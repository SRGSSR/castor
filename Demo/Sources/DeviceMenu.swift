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
            Menu {
                cast.deviceMenu()
            } label: {
                // Magic: https://stackoverflow.com/questions/76976180/how-can-i-have-a-subtitle-in-a-menu-in-swiftui
                Button(action: {}) {
                    Text("Cast")
                    if let currentDevice = cast.currentDevice {
                        Text(currentDevice.name ?? "Untitled")
                    }
                    if let image = GCKUICastButton().imageView?.image {
                      Image(uiImage: image)
                    }
                    else {
                        Image(systemName: "tv.badge.wifi")
                    }
                }
            }
        } label: {
            Image(systemName: "ellipsis.circle")
                .font(.system(size: 20))
                .tint(.accent)
        }
    }
}
