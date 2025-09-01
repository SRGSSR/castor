//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

extension Collection {
    subscript(safeIndex index: Index) -> Element? {
        guard indices.contains(index) else { return nil }
        return self[index]
    }
}
