//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import GoogleCast

/// A cast asset representing content to be played.
public struct CastAsset {
    private let rawMediaInformation: GCKMediaInformation

    /// The kind of asset.
    public let kind: Kind

    /// Metadata associated with the asset.
    public var metadata: CastMetadata? {
        .init(rawMetadata: rawMediaInformation.metadata)
    }

    /// Custom additional data associated with the asset.
    public var customData: CastCustomData? {
        guard let jsonObject = rawMediaInformation.customData else { return nil }
        return .init(jsonObject: jsonObject)
    }

    init?(rawMediaInformation: GCKMediaInformation?) {
        guard let rawMediaInformation, let kind = Self.kind(from: rawMediaInformation) else { return nil }
        self.init(rawMediaInformation: rawMediaInformation, kind: kind)
    }

    private init(kind: Kind, metadata: CastMetadata?, customData: CastCustomData?) {
        let builder = GCKMediaInformationBuilder(entity: kind.entity)

        // ---> TODO: Should be removed when entities will be supported by the SRGSSR receivers.
        switch kind {
        case let .simple(url):
            builder.contentURL = url
            builder.contentID = UUID().uuidString
        case let .custom(id):
            builder.contentID = id
        }
        // <--- TODO: Should be removed when entities will be supported by the SRGSSR receivers.

        builder.metadata = metadata?.rawMetadata
        builder.streamType = .unknown
        builder.customData = customData?.jsonObject
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
    ///   - customData: Optional custom data to associate with the asset. Use `Encodable.encoded(using:)`
    ///     to convert an `Encodable` value into a `CastCustomData`.
    public static func simple(url: URL, metadata: CastMetadata?, customData: CastCustomData? = nil) -> Self {
        .init(kind: .simple(url), metadata: metadata, customData: customData)
    }

    /// A simple asset which can be played directly.
    ///
    /// - Parameters:
    ///   - url: The URL to be played.
    ///   - metadata: The metadata associated with the asset.
    ///   - customData: Custom data associated with the asset, encoded using the default `JSONEncoder`.
    public static func simple<T>(url: URL, metadata: CastMetadata?, customData: T) -> Self where T: Encodable {
        .init(kind: .simple(url), metadata: metadata, customData: customData.encoded(using: JSONEncoder()))
    }

    /// A custom asset represented by some identifier.
    ///
    /// - Parameters:
    ///   - identifier: An identifier for the content to be played.
    ///   - metadata: The metadata associated with the asset.
    ///   - customData: Optional custom data to associate with the asset. Use `Encodable.encoded(using:)`
    ///     to convert an `Encodable` value into a `CastCustomData`.
    public static func custom(identifier: String, metadata: CastMetadata?, customData: CastCustomData? = nil) -> Self {
        .init(kind: .custom(identifier), metadata: metadata, customData: customData)
    }

    /// A custom asset represented by some identifier.
    ///
    /// - Parameters:
    ///   - identifier: An identifier for the content to be played.
    ///   - metadata: The metadata associated with the asset.
    ///   - customData: Custom data associated with the asset, encoded using the default `JSONEncoder`.
    public static func custom<T>(identifier: String, metadata: CastMetadata?, customData: T) -> Self where T: Encodable {
        .init(kind: .custom(identifier), metadata: metadata, customData: customData.encoded(using: JSONEncoder()))
    }

    private static func kind(from rawMediaInformation: GCKMediaInformation) -> Kind? {
        if let entity = rawMediaInformation.entity {
            if let url = URL(string: entity) {
                return .simple(url)
            }
            else {
                return .custom(entity)
            }
        }
        else if let url = rawMediaInformation.contentURL {
            return .simple(url)
        }
        else if let id = rawMediaInformation.contentID { // ---> TODO: Should be removed when entities will be supported by the SRGSSR receivers.
            return .custom(id)
        } // <--- TODO: Should be removed when entities will be supported by the SRGSSR receivers.
        else {
            return nil
        }
    }

    func rawItem() -> GCKMediaQueueItem {
        let builder = GCKMediaQueueItemBuilder()
        builder.mediaInformation = rawMediaInformation
        builder.autoplay = true
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

        var entity: String {
            switch self {
            case let .simple(url):
                return url.absoluteString
            case let .custom(id):
                return id
            }
        }
    }
}
