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
        static let smartNavigationEnabled = "smartNavigationEnabled"
        static let backwardSkipInterval = "backwardSkipInterval"
        static let forwardSkipInterval = "forwardSkipInterval"
    }

    @objc dynamic var presenterModeEnabled: Bool {
        bool(forKey: DemoSettingKey.presenterModeEnabled)
    }

    @objc dynamic var receiver: Receiver {
        .init(rawValue: integer(forKey: DemoSettingKey.receiver)) ?? .standard
    }

    @objc dynamic var smartNavigationEnabled: Bool {
        bool(forKey: DemoSettingKey.smartNavigationEnabled)
    }

    @objc dynamic var backwardSkipInterval: TimeInterval {
        double(forKey: DemoSettingKey.backwardSkipInterval)
    }

    @objc dynamic var forwardSkipInterval: TimeInterval {
        double(forKey: DemoSettingKey.forwardSkipInterval)
    }
}

extension UserDefaults {
    static func registerDefaults() {
        UserDefaults.standard.register(defaults: [
            DemoSettingKey.smartNavigationEnabled: true,
            DemoSettingKey.presenterModeEnabled: false,
            DemoSettingKey.backwardSkipInterval: 10,
            DemoSettingKey.forwardSkipInterval: 10
        ])
    }
}
