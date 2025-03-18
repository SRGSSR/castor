//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

public extension View {
    /// Binds to an item from a queue.
    ///
    /// - Parameters:
    ///   - item: The item to bind to the view.
    ///   - queue: The queue which fetches the item.
    ///
    /// The item is automatically fetched by the queue when the view appears.
    func bind(to item: CastPlayerItem, from queue: CastQueue) -> some View {
        onAppear {
            queue.fetch(item)
        }
    }
}
