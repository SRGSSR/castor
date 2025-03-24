//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation
import Testing

enum Operation<Item>: Equatable where Item: Equatable {
    case move(_ char: Item, _ before: Item?)
    case remove(_ char: Item)
}

@Test
func operations_empty() {
    let initial: [Character] = []
    let final: [Character] = []

    #expect(operations(initial: initial, final: final) == [])
}

@Test
func operations_identical() {
    let initial: [Character] = ["A", "B", "C", "D"]
    let final: [Character] = ["A", "B", "C", "D"]

    #expect(operations(initial: initial, final: final) == [
        Operation.move("A", nil),
        .move("B", nil),
        .move("C", nil),
        .move("D", nil),
    ])
}

@Test
func operations_not_identical() {
    let initial: [Character] = ["A", "B", "C", "D"]
    let final: [Character] = ["D", "B", "A", "C"]

    #expect(operations(initial: initial, final: final) == [
        Operation.move("A", nil),
        .move("B", "A"),
        .move("C", nil),
        .move("D", "B"),
    ])
}

@Test
func operations_remove_one() {
    let initial: [Character] = ["A", "B", "C", "D"]
    let final: [Character] = ["A", "B", "C"]

    #expect(operations(initial: initial, final: final) == [
        Operation.move("A", nil),
        .move("B", nil),
        .move("C", nil),
        .remove("D"),
    ])
}

@Test
func operations_remove_many() {
    let initial: [Character] = ["A", "B", "C", "D"]
    let final: [Character] = ["A", "C"]

    #expect(operations(initial: initial, final: final) == [
        Operation.move("A", nil),
        .remove("B"),
        .move("C", nil),
        .remove("D"),
    ])
}

func operations<Item>(initial: [Item], final: [Item]) -> [Operation<Item>] where Item: Equatable {
    var result: [Item] = []
    var operations: [Operation<Item>] = []

    for char in initial {
        if !final.contains(char) {
            operations.append(.remove(char))
        }
        else if result.isEmpty {
            result.append(char)
            operations.append(.move(char, nil))
        }
        else {
            let insertIndex = result.firstIndex { resultChar in
                final.firstIndex(of: char)! < final.firstIndex(of: resultChar)!
            }
            if let insertIndex {
                result.insert(char, at: insertIndex)
                operations.append(.move(char, result[insertIndex + 1]))
            }
            else {
                result.append(char)
                operations.append(.move(char, nil))
            }
        }
    }

    return operations
}
