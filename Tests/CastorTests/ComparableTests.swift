//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Castor

import Testing

@Test
func clamped() {
    #expect((-1).clamped(to: 0...1) == 0)
    #expect(0.clamped(to: 0...1) == 0)
    #expect(0.5.clamped(to: 0...1) == 0.5)
    #expect(1.clamped(to: 0...1) == 1)
    #expect(2.clamped(to: 0...1) == 1)
}
