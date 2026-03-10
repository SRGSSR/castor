//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Testing

@testable import Castor

@Suite
struct MutableCollectionTests {
    @Test
    func valid_index() {
        var array = [1, 2, 3]
        array[safeIndex: 1] = 4
        #expect(array == [1, 4, 3])
        #expect(array[safeIndex: 1] == 4)
    }

    @Test
    func negative_index() {
        var array = [1, 2, 3]
        array[safeIndex: -1] = 4
        #expect(array == [1, 2, 3])
        #expect(array[safeIndex: -1] == nil)
    }

    @Test
    func invalid_index() {
        var array = [1, 2, 3]
        array[safeIndex: 3] = 4
        #expect(array == [1, 2, 3])
        #expect(array[safeIndex: 3] == nil)
    }
}
