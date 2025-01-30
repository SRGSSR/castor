//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

struct Stream: Hashable, Identifiable {
    let title: String
    let url: URL

    var id: URL {
        url
    }
}
