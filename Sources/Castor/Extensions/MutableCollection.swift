//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

extension MutableCollection {
    subscript(safeIndex index: Index) -> Element? {
        get {
            indices.contains(index) ? self[index] : nil
        }
        mutating set {
            guard let newValue, indices.contains(index) else { return }
            self[index] = newValue
        }
    }
}
