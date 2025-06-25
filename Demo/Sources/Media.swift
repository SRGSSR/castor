//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Castor
import Foundation

struct Media: Hashable, Identifiable {
    enum `Type`: Hashable {
        case url(URL)
        case urn(String)
    }

    let id = UUID()
    let title: String
    let imageUrl: URL
    let type: Type

    func asset() -> CastAsset {
        let image = CastImage(url: imageUrl)
        switch type {
        case let .url(url):
            return .simple(url: url, metadata: .init(title: title, image: image))
        case let .urn(identifier):
            return .custom(identifier: identifier, metadata: .init(title: title, image: image))
        }
    }

    static func media(from item: CastPlayerItem?) -> Self? {
        guard let item, let title = item.metadata?.title, let imageUrl = item.metadata?.imageUrl() else { return nil }
        if let url = item.contentUrl {
            return .init(title: title, imageUrl: imageUrl, type: .url(url))
        }
        else {
            return nil // TODO: We should manage URNs.
        }
    }
}
