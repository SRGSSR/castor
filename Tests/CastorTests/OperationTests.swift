//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Castor

import Foundation
import Testing

@Test
func operations_empty() {
    let initial: [Character] = []
    let target: [Character] = []

    #expect(Operation.transactions(initial: initial, target: target).isEmpty == true)
}

@Test
func operations_identical() {
    let initial: [Character] = ["A", "B", "C", "D"]
    let target: [Character] = ["A", "B", "C", "D"]

    #expect(Operation.transactions(initial: initial, target: target).isEmpty == true)
}

@Test
func operations_not_identical_1() {
    let initial: [Character] = ["A", "B", "C", "D"]
    let target: [Character] = ["D", "B", "A", "C"]

    #expect(Operation.transactions(initial: initial, target: target) == [
        .move(item: "D", before: "A"),
        .move(item: "B", before: "A")
    ])
}

@Test
func operations_not_identical_2() {
    let initial: [Character] = ["A", "B", "C", "D", "E"]
    let target: [Character] = ["D", "B", "E", "A", "C"]

    #expect(Operation.transactions(initial: initial, target: target) == [
        .move(item: "D", before: "A"),
        .move(item: "B", before: "A"),
        .move(item: "E", before: "A")
    ])
}

@Test
func operations_not_identical_3() {
    let initial: [Character] = ["A", "B", "C", "D", "E"]
    let target: [Character] = ["E", "C", "A", "B", "D"]

    #expect(Operation.transactions(initial: initial, target: target) == [
        .move(item: "E", before: "A"),
        .move(item: "C", before: "A")
    ])
}

@Test
func operations_not_identical_4() {
    let initial: [Character] = ["A", "B", "C", "D", "E"]
    let target: [Character] = ["B", "D", "A", "C", "E"]

    #expect(Operation.transactions(initial: initial, target: target) == [
        .move(item: "B", before: "A"),
        .move(item: "D", before: "A")
    ])
}

@Test
func operations_not_identical_and_remove() {
    let initial: [Character] = ["A", "B", "C", "D", "E"]
    let target: [Character] = ["D", "E", "A", "C"]

    #expect(Operation.transactions(initial: initial, target: target) == [
        .remove(item: "B"),
        .move(item: "D", before: "A"),
        .move(item: "E", before: "A")
    ])
}

@Test
func operations_remove_one() {
    let initial: [Character] = ["A", "B", "C", "D"]
    let target: [Character] = ["A", "B", "C"]

    #expect(Operation.transactions(initial: initial, target: target) == [
        .remove(item: "D")
    ])
}

@Test
func operations_remove_many() {
    let initial: [Character] = ["A", "B", "C", "D"]
    let target: [Character] = ["A", "C"]

    #expect(Operation.transactions(initial: initial, target: target) == [
        .remove(item: "B"),
        .remove(item: "D")
    ])
}
