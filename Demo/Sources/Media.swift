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
    let imageUrl: URL?
    let type: Type

    init(title: String, imageUrl: URL?, type: Type) {
        self.title = title
        self.imageUrl = imageUrl
        self.type = type
    }

    init(from asset: CastAsset) {
        let title = asset.metadata.title ?? "Untitled"
        let imageUrl = asset.metadata.imageUrl()
        switch asset.kind {
        case let .simple(url):
            self.init(title: title, imageUrl: imageUrl, type: .url(url))
        case let .custom(urn):
            self.init(title: title, imageUrl: imageUrl, type: .urn(urn))
        }
    }

    func asset() -> CastAsset {
        switch type {
        case let .url(url):
            return .simple(url: url, metadata: castMetadata())
        case let .urn(identifier):
            return .custom(identifier: identifier, metadata: castMetadata())
        }
    }

    func castMetadata() -> CastMetadata {
        .init(title: title, image: castImage())
    }

    private func castImage() -> CastImage? {
        guard let imageUrl else { return nil }
        return .init(url: imageUrl)
    }
}
