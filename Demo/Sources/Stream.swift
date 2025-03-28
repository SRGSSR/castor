//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Castor
import Foundation

struct Stream: Hashable, Identifiable {
    let title: String
    let url: URL
    let imageUrl: URL

    var id: URL {
        url
    }

    func asset() -> CastAsset {
        .simple(url: url, metadata: .init(title: title, imageUrl: imageUrl))
    }
}
