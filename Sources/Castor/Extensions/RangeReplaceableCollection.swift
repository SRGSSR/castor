//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

extension RangeReplaceableCollection {
    mutating func move(from fromIndex: Index, to index: Index) {
        guard fromIndex != index else { return }
        if fromIndex > index {
            let item = remove(at: fromIndex)
            insert(item, at: index)
        }
        else {
            let item = self[fromIndex]
            insert(item, at: index)
            remove(at: fromIndex)
        }
    }
}
