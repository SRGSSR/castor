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

class PlayerViewModel: CastDataSource {
    let player = Player()

    var assets: [CastAsset] {
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

    var medias: [Media] = [] {
        didSet {
            guard medias != oldValue else { return }
            player.items = medias.map { media in
                switch media.type {
                case let .url(url):
                    return .simple(url: url)
                case let .urn(urn):
                    return .urn(urn)
                }
            }
        }
    }

    func play() {
        player.play()
    }
}
