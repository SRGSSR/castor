//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Castor

import Testing

@Test
func index_before_item_in_items_valid() {
    let currentItem = CastPlayerItem(id: 1, rawItem: nil)
    let items: [CastPlayerItem] = [
        .init(id: 0, rawItem: nil),
        currentItem,
        .init(id: 2, rawItem: nil)
    ]

    #expect(CastQueue.index(before: currentItem, in: items) == 0)
}

@Test
func index_after_item_in_items_valid() {
    let currentItem = CastPlayerItem(id: 1, rawItem: nil)
    let items: [CastPlayerItem] = [
        .init(id: 0, rawItem: nil),
        currentItem,
        .init(id: 2, rawItem: nil)
    ]

    #expect(CastQueue.index(after: currentItem, in: items) == 2)
}

@Test
func index_before_item_in_items_invalid() {
    let currentItem = CastPlayerItem(id: 0, rawItem: nil)
    let items: [CastPlayerItem] = [
        currentItem,
        .init(id: 1, rawItem: nil),
        .init(id: 2, rawItem: nil)
    ]

    #expect(CastQueue.index(before: currentItem, in: items) == nil)
}

@Test
func index_after_item_in_items_invalid() {
    let currentItem = CastPlayerItem(id: 2, rawItem: nil)
    let items: [CastPlayerItem] = [
        .init(id: 0, rawItem: nil),
        .init(id: 1, rawItem: nil),
        currentItem
    ]

    #expect(CastQueue.index(after: currentItem, in: items) == nil)
}
