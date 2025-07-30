//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

@objc
enum PlayerType: Int, CaseIterable {
    case standard
    case custom

    var name: LocalizedStringKey {
        switch self {
        case .standard:
            "Standard"
        case .custom:
            "Custom"
        }
    }
}
