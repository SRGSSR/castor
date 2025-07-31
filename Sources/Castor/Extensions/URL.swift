//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

extension URL {
    init?(castableString string: String) {
        guard let components = URLComponents(string: string), ["http", "https"].contains(components.scheme),
              let url = components.url else { return nil }
        self = url
    }
}
