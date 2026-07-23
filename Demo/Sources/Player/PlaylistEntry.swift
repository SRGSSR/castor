//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation
import PillarboxPlayer

struct PlaylistEntry: Hashable, Identifiable {
    let media: Media
    let item: PlayerItem

    var id: UUID {
        media.id
    }

    init(media: Media) {
        self.media = media
        self.item = media.item()
    }
}
