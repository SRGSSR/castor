//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import GoogleCast

/// An option for media selection (audible, legible, etc.).
public struct CastMediaTrack: Hashable {
    private let rawTrack: GCKMediaTrack

    var trackIdentifier: Int {
        rawTrack.identifier
    }

    var mediaCharacteristic: AVMediaCharacteristic? {
        rawTrack.type.mediaCharacteristic()
    }

    var displayName: String {
        if let displayName = rawTrack.name {
            return displayName
        }
        else {
            guard let languageCode = rawTrack.languageCode,
                  let displayName = Locale.current.localizedString(forIdentifier: languageCode) else {
                return String(localized: "Undefined", bundle: .module, comment: "Undefined language")
            }
            return displayName.localizedCapitalized
        }
    }

    init(rawTrack: GCKMediaTrack) {
        self.rawTrack = rawTrack
    }
}
