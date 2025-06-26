//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Castor
import PillarboxPlayer
import PillarboxCoreBusiness
import SwiftUI

class PlayerViewModel: CastDataSource {
    let player = Player()

    var assets: [CastAsset] {
        guard let media else { return [] }
        let metadata = CastMetadata(title: media.title, image: .init(url: media.imageUrl))
        switch media.type {
        case let .url(url):
            return [.simple(url: url, metadata: metadata)]
        case let .urn(urn):
            return [.custom(identifier: urn, metadata: metadata)]
        }
    }

    var media: Media? {
        didSet {
            guard media != oldValue else { return }
            switch media?.type {
            case let .url(url):
                player.items = [.simple(url: url)]
            case let .urn(urn):
                player.items = [.urn(urn)]
            default:
                player.items = []
            }
        }
    }

    func play() {
        player.play()
    }
}
