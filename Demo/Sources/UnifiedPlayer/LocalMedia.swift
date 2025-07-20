//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import PillarboxPlayer

struct LocalMedia: Hashable {
    let media: Media
    let item: PlayerItem

    init(media: Media) {
        self.media = media
        self.item = media.item()
    }
}

private extension Media {
    func item() -> PlayerItem {
        switch type {
        case let .url(url):
            return .simple(url: url, metadata: self)
        case let .urn(identifier):
            return .urn(identifier)
        }
    }
}

extension Media: AssetMetadata {
    var playerMetadata: PlayerMetadata {
        if let imageUrl {
            .init(title: title, imageSource: .url(standardResolution: imageUrl))
        }
        else {
            .init(title: title)
        }
    }
}
