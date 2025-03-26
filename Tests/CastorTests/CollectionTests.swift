//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Testing

@testable import Castor

@Suite("Collection")
struct CollectionTests {
    @Test
    func safe_index() {
        #expect([1, 2, 3][safeIndex: 0] == 1)
        #expect([1, 2, 3][safeIndex: -1] == nil)
        #expect([1, 2, 3][safeIndex: 3] == nil)
    }
}
