//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Castor
import Foundation
import PillarboxPlayer

class UnifiedPlayerViewModel: ObservableObject {
}

extension UnifiedPlayerViewModel: CastDelegate {
    func castStartSession() {
        print("--> start cast session")
    }

    func castEndSession(with state: CastResumeState?) {
        print("--> end cast session")
    }

    func castAsset(from information: CastMediaInformation) -> CastAsset? {
        nil
    }
}
