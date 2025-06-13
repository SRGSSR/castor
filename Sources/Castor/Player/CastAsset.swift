//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import GoogleCast

/// A cast asset representing content to be played.
public struct CastAsset {
    private enum Kind {
        case simple(URL)
        case custom(String)

        func mediaInformationBuilder() -> GCKMediaInformationBuilder {
            switch self {
            case let .simple(url):
                let builder = GCKMediaInformationBuilder(contentURL: url)
                // TODO: This workaround should be removed.
                // A random contentID is currently set to enable playback of URL based content using the SRGSSR receiver.
                builder.contentID = UUID().uuidString
                return builder
            case let .custom(id):
                let builder = GCKMediaInformationBuilder()
                builder.contentID = id
                return builder
            }
        }
    }

    private let kind: Kind
    private let metadata: CastMetadata
    private let configuration: CastPlaybackConfiguration

    /// A simple asset which can be played directly.
    ///
    /// - Parameters:
    ///   - url: The URL to be played.
    ///   - metadata: The metadata associated with the asset.
    ///   - configuration: The playback configuration.
    /// - Returns: The asset.
    public static func simple(url: URL, metadata: CastMetadata, configuration: CastPlaybackConfiguration = .default) -> Self {
        .init(kind: .simple(url), metadata: metadata, configuration: configuration)
    }

    /// A custom asset represented by some identifier..
    ///
    /// - Parameters:
    ///   - identifier: An identifier for the content to be played.
    ///   - metadata: The metadata associated with the asset.
    ///   - configuration: The playback configuration.
    /// - Returns: The asset.
    public static func custom(identifier: String, metadata: CastMetadata, configuration: CastPlaybackConfiguration = .default) -> Self {
        .init(kind: .custom(identifier), metadata: metadata, configuration: configuration)
    }

    func rawItem() -> GCKMediaQueueItem {
        let builder = GCKMediaQueueItemBuilder()
        builder.mediaInformation = mediaInformation()
        builder.autoplay = configuration.autoplay
        builder.startTime = configuration.startTime.seconds
        return builder.build()
    }

    private func mediaInformation() -> GCKMediaInformation {
        let builder = kind.mediaInformationBuilder()
        builder.metadata = metadata.rawMetadata
        builder.streamType = .unknown
        return builder.build()
    }
}
