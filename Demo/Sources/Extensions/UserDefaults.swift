//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

extension UserDefaults {
    enum DemoSettingKey {
        static let receiver = "receiver"
        static let presenterModeEnabled = "presenterModeEnabled"
    }

    @objc dynamic var presenterModeEnabled: Bool {
        bool(forKey: DemoSettingKey.presenterModeEnabled)
    }

    @objc dynamic var receiver: Receiver {
        .init(rawValue: integer(forKey: DemoSettingKey.receiver)) ?? .standard
    }
}
