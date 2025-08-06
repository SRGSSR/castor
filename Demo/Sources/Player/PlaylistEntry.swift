//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import CoreMedia
import PillarboxPlayer

struct PlaylistEntry: Hashable {
    let media: Media
    let item: PlayerItem

    init(media: Media, startTime: @autoclosure @escaping () -> CMTime = .zero) {
        self.media = media
        self.item = media.playerItem(with: .init(position: at(startTime())))
    }
}
