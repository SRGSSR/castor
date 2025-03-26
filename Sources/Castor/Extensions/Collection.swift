//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

extension Collection {
    /// Safely returns the item at the specified index.
    /// 
    /// - Parameter index: The index.
    /// - Returns: The item at the specified index or `nil` if the index is not within range.
    subscript(safeIndex index: Index) -> Element? {
        guard indices.contains(index) else { return nil }
        return self[index]
    }
}
