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
        setMediaSelection(from: resumeState, for: .audible)
        setMediaSelection(from: resumeState, for: .legible)
    }

    private func setMediaSelection(from resumeState: CastResumeState, for characteristic: AVMediaCharacteristic) {
        if let language = resumeState.mediaSelectionLanguage(for: characteristic) {
            setMediaSelection(preferredLanguages: [language], for: characteristic)
        }
        else {
            setMediaSelection(preferredLanguages: [], for: characteristic)
        }
    }
}
