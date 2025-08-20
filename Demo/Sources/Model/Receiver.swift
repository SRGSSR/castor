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
    case amtins
    case androidTv

    var identifier: String {
        switch self {
        case .standard:
            kGCKDefaultMediaReceiverApplicationID // "CC1AD845"
        case .drm:
            "A12D4273"
        case .srgssr:
            "1AC2931D"
        case .amtins:
            "EB05B588"
        case .androidTv:
            "5718ACDA"
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
        case .amtins:
            "amtins"
        case .androidTv:
            "Android TV"
        }
    }

    var isSrgSsrReceiver: Bool {
        switch self {
        case .srgssr, .amtins, .androidTv:
            true
        default:
            false
        }
    }
}
