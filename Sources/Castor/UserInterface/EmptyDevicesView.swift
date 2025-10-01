//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

struct EmptyDevicesView: View {
    var body: some View {
        UnavailableView {
            Label {
                Text("No devices available", bundle: .module, comment: "Message displayed when no Cast devices are available")
            } icon: {
                Image(systemName: imageName)
            }
        } description: {
            Text(
                "Check your Wi-Fi network and make sure Local Network Access is on.",
                bundle: .module,
                comment: "Action suggested when no Cast receivers are found"
            )
            if canOpenSettings() {
                Button(action: openSettings) {
                    Text("Open Settings", bundle: .module, comment: "Open settings button accessibility label")
                }
            }
        }
    }

    private var imageName: String {
        if #available(iOS 17.0, *) {
            return "tv.badge.wifi.fill"
        }
        else {
            return "tv.fill"
        }
    }
}

private extension EmptyDevicesView {
    static let settingsUrl = {
        if ProcessInfo.processInfo.isRunningOnMac {
            // https://gist.github.com/rmcdongit/f66ff91e0dad78d4d6346a75ded4b751
            URL(string: "x-apple.systempreferences:com.apple.preference.security")!
        }
        else {
            URL(string: UIApplication.openSettingsURLString)!
        }
    }()

    func openSettings() {
        UIApplication.shared.open(Self.settingsUrl)
    }

    func canOpenSettings() -> Bool {
        UIApplication.shared.canOpenURL(Self.settingsUrl)
    }
}

#Preview {
    EmptyDevicesView()
}
