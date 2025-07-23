//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import GoogleCast

/// The media information useful for casting.
/// TODO: Rename as CastResource
public struct CastMediaInformation {
    let rawMediaInformation: GCKMediaInformation

    /// The kind of content.
    public let kind: Kind

    /// The metadata.
    public var metadata: CastMetadata? {
        .init(rawMetadata: rawMediaInformation.metadata)
    }

    public var customData: Any? {
        rawMediaInformation.customData
    }

    init?(rawMediaInformation: GCKMediaInformation) {
        guard let kind = Self.kind(from: rawMediaInformation) else { return nil }
        self.init(rawMediaInformation: rawMediaInformation, kind: kind)
    }

    private init(rawMediaInformation: GCKMediaInformation, kind: Kind) {
        self.rawMediaInformation = rawMediaInformation
        self.kind = kind
    }

    private init(kind: Kind, metadata: CastMetadata?, customData: Any?) {
        let builder = kind.mediaInformationBuilder()
        builder.metadata = metadata?.rawMetadata
        builder.customData = customData
        builder.streamType = .unknown
        self.init(rawMediaInformation: builder.build(), kind: kind)

    }

    public static func simple(url: URL, metadata: CastMetadata?, customData: Any? = nil) -> Self {
        Self.init(kind: .simple(url), metadata: metadata, customData: customData)
    }

    public static func custom(identifier: String, metadata: CastMetadata?, customData: Any? = nil) -> Self {
        Self.init(kind: .custom(identifier), metadata: metadata, customData: customData)
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
}

public extension CastMediaInformation {
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
