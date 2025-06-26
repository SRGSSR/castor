//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Castor
import CoreMedia
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
    let startTime: CMTime?

    init(title: String, imageUrl: URL, type: Type, startTime: CMTime? = nil) {
        self.title = title
        self.imageUrl = imageUrl
        self.type = type
        self.startTime = startTime
    }

    func asset() -> CastAsset {
        let image = CastImage(url: imageUrl)
        let configuration = CastPlaybackConfiguration(startTime: startTime ?? .invalid)
        switch type {
        case let .url(url):
            return .simple(url: url, metadata: .init(title: title, image: image), configuration: configuration)
        case let .urn(identifier):
            return .custom(identifier: identifier, metadata: .init(title: title, image: image), configuration: configuration)
        }
    }

    static func media(from asset: CastAsset?, startTime: CMTime? = nil) -> Self? {
        guard let asset, let title = asset.metadata.title, let imageUrl = asset.metadata.imageUrl() else { return nil }
        switch asset.kind {
        case let .simple(url):
            return .init(title: title, imageUrl: imageUrl, type: .url(url), startTime: startTime)
        case let .custom(urn):
            return .init(title: title, imageUrl: imageUrl, type: .urn(urn), startTime: startTime)
        }
    }
}
