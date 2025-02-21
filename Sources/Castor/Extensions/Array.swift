//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

extension Array {
    subscript(insertAt index: Int) -> Element? {
        get {
            indices.contains(index) ? self[index] : nil
        }
        set {
            if let value = newValue, index <= count {
                insert(value, at: index)
            }
        }
    }
}
