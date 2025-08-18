//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Castor
import PillarboxPlayer

extension Player {
    func setMediaSelection(from resumeState: CastResumeState) {
        resumeState.mediaSelectionCharacteristics.forEach { characteristic in
            guard let language = resumeState.mediaSelectionLanguage(for: characteristic) else {
                return
            }
            setMediaSelection(preferredLanguages: [language], for: characteristic)
        }
    }
}
