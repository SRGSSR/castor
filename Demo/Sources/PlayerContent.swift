//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import CoreMedia

struct PlayerContent: Hashable {
    let medias: [Media]
    let startIndex: Int
    let startTime: CMTime

    init?(medias: [Media], startIndex: Int = 0, startTime: CMTime = .zero) {
        guard medias.indices.contains(startIndex) else { return nil }
        self.medias = medias
        self.startIndex = startIndex
        self.startTime = startTime
    }
}
