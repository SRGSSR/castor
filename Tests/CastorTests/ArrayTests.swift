//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Testing

@testable import Castor

@Suite
struct ArrayTests {
    @Test
    func chunk_empty() {
        #expect([Int]().chunked(into: 1) == [])
    }

    @Test
    func chunk_small() {
        #expect([1, 2].chunked(into: 3) == [[1, 2]])
    }

    @Test
    func chunk_exactly_one() {
        #expect([1, 2, 3].chunked(into: 3) == [[1, 2, 3]])
    }

    @Test
    func chunk_many() {
        #expect([1, 2, 3, 4, 5].chunked(into: 3) == [[1, 2, 3], [4, 5]])
    }

    @Test
    func chunk_exactly_many() {
        #expect([1, 2, 3, 4, 5, 6].chunked(into: 3) == [[1, 2, 3], [4, 5, 6]])
    }
}
