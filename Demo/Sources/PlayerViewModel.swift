//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Castor
import PillarboxCoreBusiness
import PillarboxPlayer
import SwiftUI

class PlayerViewModel {
    let player = Player()
    private var medias: [Media] = []

    func play() {
        player.play()
    }

    func setMedias(_ medias: [Media], startIndex: Int, startTime: CMTime) {
        guard medias != self.medias else { return }
        self.medias = medias
        player.items = medias.enumerated().map { index, media in
            let configuration = index == startIndex ? PlaybackConfiguration(position: at(startTime)) : PlaybackConfiguration()
            switch media.type {
            case let .url(url):
                return .simple(url: url, configuration: configuration)
            case let .urn(urn):
                return .urn(urn, configuration: configuration)
            }
        }
        player.currentItem = player.items[safeIndex: startIndex]
    }
}

extension PlayerViewModel: Castable {
    func castResumeState() -> CastResumeState? {
        .init(assets: castAssets(), index: currentIndex() ?? 0, time: player.time())
    }

    private func castAssets() -> [CastAsset] {
        medias.map { media in
            switch media.type {
            case let .url(url):
                return .simple(url: url, metadata: media.castMetadata())
            case let .urn(urn):
                return .custom(identifier: urn, metadata: media.castMetadata())
            }
        }
    }

    private func currentIndex() -> Int? {
        guard let currentItem = player.currentItem else { return nil }
        return player.items.firstIndex(of: currentItem)
    }
}
