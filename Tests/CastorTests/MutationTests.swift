//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Testing

@testable import Castor

@Suite
struct MutationTests {
    @Test
    func empty() {
        let initial: [String] = []
        let final: [String] = []

        #expect(Mutation.mutations(from: initial, to: final).isEmpty == true)
    }

    @Test
    func remove_one_1() {
        let initial = ["A"]
        let final: [String] = []

        #expect(Mutation.mutations(from: initial, to: final) == [
            .remove(element: "A")
        ])
    }

    @Test
    func remove_one_2() {
        let initial = ["A", "B", "C", "D"]
        let final = ["A", "B", "C"]

        #expect(Mutation.mutations(from: initial, to: final) == [
            .remove(element: "D")
        ])
    }

    @Test
    func remove_many() {
        let initial = ["A", "B", "C", "D"]
        let final = ["A", "C"]

        #expect(Mutation.mutations(from: initial, to: final) == [
            .remove(element: "D"),
            .remove(element: "B")
        ])
    }

    @Test
    func shift() {
        let initial = ["A", "B", "C", "D", "E"]
        let final = ["B", "C", "D", "E", "A"]

        #expect(Mutation.mutations(from: initial, to: final) == [
            .move(element: "A", before: nil)
        ])
    }

    @Test
    func identical() {
        let initial = ["A", "B", "C", "D"]
        let final = ["A", "B", "C", "D"]

        #expect(Mutation.mutations(from: initial, to: final).isEmpty == true)
    }

    @Test
    func not_identical_1() {
        let initial = ["A", "B", "C", "D"]
        let final = ["D", "B", "A", "C"]

        #expect(Mutation.mutations(from: initial, to: final) == [
            .move(element: "D", before: "B"),
            .move(element: "A", before: "C")
        ])
    }
    @Test
    func not_identical_2() {
        let initial = ["A", "B", "C", "D", "E"]
        let final = ["D", "B", "E", "A", "C"]

        #expect(Mutation.mutations(from: initial, to: final) == [
            .move(element: "B", before: "E"),
            .move(element: "A", before: nil),
            .move(element: "C", before: nil)
        ])
    }

    @Test
    func not_identical_3() {
        let initial = ["A", "B", "C", "D", "E"]
        let final = ["E", "C", "A", "B", "D"]

        #expect(Mutation.mutations(from: initial, to: final) == [
            .move(element: "E", before: "A"),
            .move(element: "C", before: "A")
        ])
    }

    @Test
    func not_identical_4() {
        let initial = ["A", "B", "C", "D", "E"]
        let final = ["B", "D", "A", "C", "E"]

        #expect(Mutation.mutations(from: initial, to: final) == [
            .move(element: "A", before: "E"),
            .move(element: "C", before: "E")
        ])
    }

    @Test
    func not_identical_and_remove() {
        let initial = ["A", "B", "C", "D", "E"]
        let final = ["D", "E", "A", "C"]

        #expect(Mutation.mutations(from: initial, to: final) == [
            .remove(element: "B"),
            .move(element: "A", before: nil),
            .move(element: "C", before: nil)
        ])
    }
}
