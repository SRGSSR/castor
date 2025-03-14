//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

public extension View {
    /// Binds to an item from a media queue.
    ///
    /// - Parameters:
    ///   - item: The item to bind to the view.
    ///   - mediaQueue: The media queue which fetches the item.
    ///
    /// The item is automatically fetched by the media queue when the view appears.
    func bind(to item: CastPlayerItem, from mediaQueue: MediaQueue) -> some View {
        onAppear {
            mediaQueue.fetch(item)
        }
    }
}
