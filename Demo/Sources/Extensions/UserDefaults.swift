//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

extension UserDefaults {
    enum DemoSettingKey: String, CaseIterable {
        case receiver
    }

    @objc dynamic var receiver: Receiver {
        .init(rawValue: integer(forKey: DemoSettingKey.receiver.rawValue)) ?? .standard
    }
}
