//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation
import GoogleCast

/// An cast asset representing content to be played.
public struct CastAsset {
    private enum Kind {
        case simple(URL)
        case custom(String)

        func mediaInformationBuilder() -> GCKMediaInformationBuilder {
            switch self {
            case let .simple(url):
                return GCKMediaInformationBuilder(contentURL: url)
            case let .custom(id):
                let builder = GCKMediaInformationBuilder()
                builder.contentID = id
                return builder
            }
        }
    }

    private let kind: Kind
    private let metadata: CastMetadata

    /// Simple assets which can be played directly.
    public static func simple(url: URL, metadata: CastMetadata) -> Self {
        .init(kind: .simple(url), metadata: metadata)
    }

    /// Custom assets which require a custom identifier.
    public static func custom(identifier: String, metadata: CastMetadata) -> Self {
        .init(kind: .custom(identifier), metadata: metadata)
    }

    func rawItem() -> GCKMediaQueueItem {
        let builder = GCKMediaQueueItemBuilder()
        builder.mediaInformation = mediaInformation()
        builder.autoplay = true
        return builder.build()
    }

    private func mediaInformation() -> GCKMediaInformation {
        let builder = kind.mediaInformationBuilder()
        builder.metadata = metadata.rawMetadata
        return builder.build()
    }
}
