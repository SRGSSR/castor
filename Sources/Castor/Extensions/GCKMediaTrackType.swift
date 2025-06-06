//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import GoogleCast

extension GCKMediaTrackType {
    func mediaCharacteristic() -> AVMediaCharacteristic? {
        switch self {
        case .audio:
            return .audible
        case .text:
            return .legible
        default:
            return nil
        }
    }
}
