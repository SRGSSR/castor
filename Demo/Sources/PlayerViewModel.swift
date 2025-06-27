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

    var medias: [Media] = [] {
        didSet {
            guard medias != oldValue else { return }
            player.items = medias.map { media in
                switch media.type {
                case let .url(url):
                    return .simple(url: url, configuration: .init(position: at(media.startTime ?? .zero)))
                case let .urn(urn):
                    return .urn(urn, configuration: .init(position: at(media.startTime ?? .zero)))
                }
            }
        }
    }

    func play() {
        player.play()
    }
}

extension PlayerViewModel: Castable {
    func castResumeState() -> CastResumeState? {
        .init(assets: castAssets(), index: currentIndex() ?? 0, time: player.time())
    }

    private func castAssets() -> [CastAsset] {
        medias.map { media in
            let metadata = CastMetadata(title: media.title, image: .init(url: media.imageUrl))
            switch media.type {
            case let .url(url):
                return .simple(url: url, metadata: metadata)
            case let .urn(urn):
                return .custom(identifier: urn, metadata: metadata)
            }
        }
    }

    private func currentIndex() -> Int? {
        guard let currentItem = player.currentItem else { return nil }
        return player.items.firstIndex(of: currentItem)
    }
}
