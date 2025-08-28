//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Castor
import PillarboxPlayer

extension CastResumeState {
    mutating func setMediaSelection(from player: Player) {
        player.mediaSelectionCharacteristics.forEach { characteristic in
            switch player.selectedMediaOption(for: characteristic) {
            case let .on(option):
                let language = option.locale?.language.languageCode?.identifier
                setMediaSelection(language: language, for: characteristic)
            default:
                break
            }
        }
    }
}
