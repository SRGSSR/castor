//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

enum Operation<Item>: Equatable where Item: Equatable {
    case move(_ char: Item, _ before: Item?)
    case remove(_ char: Item)

    // swiftlint:disable:next cyclomatic_complexity
    static func transactions(initial: [Item], target: [Item]) -> [Self] {
        var operations: [Self] = []
        var final: [Item] = initial

        if initial == target {
            return operations
        }

        if final.count != target.count {
            final.removeAll { fChar in
                let isRemoved = !target.contains(fChar)
                if isRemoved {
                    operations.append(.remove(fChar))
                }
                return isRemoved
            }
        }

        for (tIndex, tChar) in target.enumerated() {
            let isTargetCharAtTheRightPlace = final[tIndex] == target[tIndex]
            if isTargetCharAtTheRightPlace {
                continue
            }
            else {
                if let indexOfTargetCharInFinal = final.firstIndex(of: tChar) {
                    final.remove(at: indexOfTargetCharInFinal)
                    final.insert(tChar, at: tIndex)
                    let before = tIndex + 1 < final.count ? final[tIndex + 1] : nil
                    operations.append(.move(tChar, before))
                }
            }
        }
        return operations
    }
}
