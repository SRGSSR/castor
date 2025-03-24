//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation
import Testing

enum Operation: Equatable {
    case move(_ char: Character, _ before: Character?)
    case remove(_ char: Character)
}

@Test
func operations_empty() {
    let initial: [Character] = []
    let target: [Character] = []

    #expect(operations(initial: initial, target: target) == [])
}

@Test
func operations_identical() {
    let initial: [Character] = ["A", "B", "C", "D"]
    let target: [Character] = ["A", "B", "C", "D"]

    #expect(operations(initial: initial, target: target) == [])
}

@Test
func operations_not_identical_1() {
    let initial: [Character] = ["A", "B", "C", "D"]
    let target: [Character] = ["D", "B", "A", "C"]

    #expect(operations(initial: initial, target: target) == [
        .move("D", "A"),
        .move("B", "A"),
    ])
}

@Test
func operations_not_identical_2() {
    let initial: [Character] = ["A", "B", "C", "D", "E"]
    let target: [Character] = ["D", "B", "E", "A", "C"]

    #expect(operations(initial: initial, target: target) == [
        .move("D", "A"),
        .move("B", "A"),
        .move("E", "A"),
    ])
}

@Test
func operations_remove_one() {
    let initial: [Character] = ["A", "B", "C", "D"]
    let target: [Character] = ["A", "B", "C"]

    #expect(operations(initial: initial, target: target) == [
        .remove("D"),
    ])
}

@Test
func operations_remove_many() {
    let initial: [Character] = ["A", "B", "C", "D"]
    let target: [Character] = ["A", "C"]

    #expect(operations(initial: initial, target: target) == [
        .remove("B"),
        .remove("D"),
    ])
}

func operations(initial: [Character], target: [Character]) -> [Operation] {
    var operations: [Operation] = []
    var final: [Character] = initial

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
