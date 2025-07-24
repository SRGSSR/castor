//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import GoogleCast

/// A cast asset representing content to be played.
public struct CastAsset {
    let rawMediaInformation: GCKMediaInformation

    /// The kind of content.
    public let kind: Kind

    /// The metadata.
    public var metadata: CastMetadata? {
        .init(rawMetadata: rawMediaInformation.metadata)
    }

    /// Custom data associated with the asset.
    public var customData: Any? {
        rawMediaInformation.customData
    }

    init?(rawMediaInformation: GCKMediaInformation) {
        guard let kind = Self.kind(from: rawMediaInformation) else { return nil }
        self.init(rawMediaInformation: rawMediaInformation, kind: kind)
    }

    private init(kind: Kind, metadata: CastMetadata?, customData: Any?) {
        let builder = kind.mediaInformationBuilder()
        builder.metadata = metadata?.rawMetadata
        builder.streamType = .unknown
        builder.customData = customData
        self.init(rawMediaInformation: builder.build(), kind: kind)
    }

    private init(rawMediaInformation: GCKMediaInformation, kind: Kind) {
        self.rawMediaInformation = rawMediaInformation
        self.kind = kind
    }

    /// A simple asset which can be played directly.
    ///
    /// - Parameters:
    ///   - url: The URL to be played.
    ///   - metadata: The metadata associated with the asset.
    ///   - customData: Custom data associated with the asset.
    public static func simple(url: URL, metadata: CastMetadata?, customData: Any? = nil) -> Self {
        .init(kind: .simple(url), metadata: metadata, customData: customData)
    }

    /// A custom asset represented by some identifier..
    ///
    /// - Parameters:
    ///   - identifier: An identifier for the content to be played.
    ///   - metadata: The metadata associated with the asset.
    ///   - customData: Custom data associated with the asset.
    public static func custom(identifier: String, metadata: CastMetadata?, customData: Any? = nil) -> Self {
        .init(kind: .custom(identifier), metadata: metadata, customData: customData)
    }

    private static func kind(from rawMediaInformation: GCKMediaInformation) -> Kind? {
        if let identifier = rawMediaInformation.contentID {
            return .custom(identifier)
        }
        else if let url = rawMediaInformation.contentURL {
            return .simple(url)
        }
        else {
            return nil
        }
    }

    func rawItem() -> GCKMediaQueueItem {
        let builder = GCKMediaQueueItemBuilder()
        builder.mediaInformation = rawMediaInformation
        return builder.build()
    }
}

public extension CastAsset {
    /// Represents the type of the asset.
    enum Kind {
        /// A type of asset identified by an URL.
        case simple(URL)

        /// A type of asset identified by an identifier.
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
}
