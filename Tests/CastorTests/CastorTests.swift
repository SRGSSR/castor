//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Castor
import Testing

@Test
func move_forward() {
    var array = [1, 2, 3, 4, 5, 6, 7]
    array.move(from: 2, to: 5)
    #expect(array == [1, 2, 4, 5, 3, 6, 7])
}

@Test
func move_backward() {
    var array = [1, 2, 3, 4, 5, 6, 7]
    array.move(from: 5, to: 2)
    #expect(array == [1, 2, 6, 3, 4, 5, 7])
}

@Test
func move_to_end() {
    var array = [1, 2, 3, 4, 5, 6, 7]
    array.move(from: 2, to: 7)
    #expect(array == [1, 2, 4, 5, 6, 7, 3])
}

@Test
func move_same_item() {
    var array = [1, 2, 3, 4, 5, 6, 7]
    array.move(from: 2, to: 2)
    #expect(array == [1, 2, 3, 4, 5, 6, 7])
}

@Test
func move_from_invalid_index() {
    // TODO: Implement once death tests are available: https://forums.swift.org/t/exit-tests-death-tests-and-you/71186
}

@Test
func move_to_invalid_index() {
    // TODO: Implement once death tests are available: https://forums.swift.org/t/exit-tests-death-tests-and-you/71186
}
