//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import CoreMedia
import PillarboxPlayer

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

    func items() -> [PlayerItem] {
        medias.enumerated().map { index, media in
            switch media.type {
            case let .url(url):
                return .simple(url: url, configuration: itemConfiguration(at: index))
            case let .urn(urn):
                return .urn(urn, configuration: itemConfiguration(at: index))
            }
        }
    }

    private func itemConfiguration(at index: Int) -> PlaybackConfiguration {
        index == startIndex ? .init(position: at(startTime)) : .init()
    }
}
