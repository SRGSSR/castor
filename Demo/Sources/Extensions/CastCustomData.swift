//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Castor

extension CastCustomData {
    private struct CustomData: Decodable {
        let chapters: [Chapter]
    }

    func chapters() -> [Chapter] {
        decoded(as: CustomData.self)?.chapters ?? []
    }
}
