//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Castor
import PillarboxPlayer

extension Player {
    func setMediaSelection(from resumeState: CastResumeState) {
        [AVMediaCharacteristic.audible, .legible].forEach { characteristic in
            if let language = resumeState.mediaSelectionLanguage(for: characteristic) {
                setMediaSelection(preferredLanguages: [language], for: characteristic)
            }
            else {
                setMediaSelection(preferredLanguages: [], for: characteristic)
            }
        }
    }
}
