//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Castor
import Foundation
import PillarboxPlayer

protocol UnifiedPlayer: AnyObject, ObservableObject {
    var shouldPlay: Bool { get }

    func togglePlayPause()
}

extension Player: UnifiedPlayer {}
extension CastPlayer: UnifiedPlayer {}
