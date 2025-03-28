//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import GoogleCast
import SwiftUI

@objc
enum Receiver: Int, CaseIterable {
    case standard
    case drm
    case srgssr

    var identifier: String {
        switch self {
        case .standard:
            kGCKDefaultMediaReceiverApplicationID // "CC1AD845"
        case .drm:
            "A12D4273"
        case .srgssr:
            "1AC2931D"
        }
    }

    var name: LocalizedStringKey {
        switch self {
        case .standard:
            "Standard"
        case .drm:
            "DRM enabled"
        case .srgssr:
            "SRG SSR"
        }
    }
}
