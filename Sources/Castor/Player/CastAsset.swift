//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import GoogleCast

/// An object representing an asset that can be played by a `CastPlayer`.
public struct CastAsset {
    private let rawMediaInformation: GCKMediaInformation

    /// The kind of asset.
    public let kind: Kind

    /// Metadata associated with the asset.
    public var metadata: CastMetadata? {
        .init(rawMetadata: rawMediaInformation.metadata)
    }

    /// Custom data associated with the asset.
    ///
    /// Use this data to convey arbitrary information between your sender and receiver.
    public var customData: CastCustomData? {
        guard let jsonObject = rawMediaInformation.customData else { return nil }
        return .init(jsonObject: jsonObject)
    }

    init?(rawMediaInformation: GCKMediaInformation?) {
        guard let rawMediaInformation, let kind = Self.kind(from: rawMediaInformation) else { return nil }
        self.init(rawMediaInformation: rawMediaInformation, kind: kind)
    }

    private init(kind: Kind, metadata: CastMetadata?, customData: CastCustomData?) {
        let builder = kind.mediaInformationBuilder()
        builder.metadata = metadata?.rawMetadata
        builder.streamType = .none
        builder.customData = customData?.jsonObject
        self.init(rawMediaInformation: builder.build(), kind: kind)
    }

    private init(rawMediaInformation: GCKMediaInformation, kind: Kind) {
        self.rawMediaInformation = rawMediaInformation
        self.kind = kind
    }

    /// An asset represented by an entity.
    ///
    /// - Parameters:
    ///   - entity: An entity for the content to be played.
    ///   - metadata: The metadata associated with the asset.
    ///   - customData: Optional custom data to associate with the asset. Use `Encodable.encoded(using:)`
    ///     to convert an `Encodable` value into a `CastCustomData`.
    ///
    /// An entity is the suggested property to use in your implementation for both your sender and receiver apps.
    /// It is a deep link URL that represents a single media item and that your receiver should be able to handle.
    public static func entity(_ entity: String, metadata: CastMetadata?, customData: CastCustomData? = nil) -> Self {
        .init(kind: .entity(entity), metadata: metadata, customData: customData)
    }

    /// An asset represented by an entity.
    ///
    /// - Parameters:
    ///   - entity: An entity for the content to be played.
    ///   - metadata: The metadata associated with the asset.
    ///   - customData: Optional custom data to associate with the asset, encoded using the default `JSONEncoder`.
    ///     to convert an `Encodable` value into a `CastCustomData`.
    ///
    /// An entity is the suggested property to use in your implementation for both your sender and receiver apps.
    /// It is a deep link URL that represents a single media item and that your receiver should be able to handle.
    public static func entity<T>(_ entity: String, metadata: CastMetadata?, customData: T) -> Self where T: Encodable {
        .init(kind: .entity(entity), metadata: metadata, customData: customData.encoded(using: JSONEncoder()))
    }

    /// An asset represented by an identifier.
    ///
    /// - Parameters:
    ///   - identifier: The identifier for the content to be played.
    ///   - metadata: The metadata associated with the asset.
    ///   - customData: Optional custom data to associate with the asset. Use `Encodable.encoded(using:)`
    ///     to convert an `Encodable` value into a `CastCustomData`.
    public static func identifier(_ identifier: String, metadata: CastMetadata?, customData: CastCustomData? = nil) -> Self {
        .init(kind: .identifier(identifier), metadata: metadata, customData: customData)
    }

    /// An asset represented by an identifier.
    ///
    /// - Parameters:
    ///   - identifier: The identifier for the content to be played.
    ///   - metadata: The metadata associated with the asset.
    ///   - customData: Optional custom data to associate with the asset, encoded using the default `JSONEncoder`.
    public static func identifier<T>(_ identifier: String, metadata: CastMetadata?, customData: T) -> Self where T: Encodable {
        .init(kind: .identifier(identifier), metadata: metadata, customData: customData.encoded(using: JSONEncoder()))
    }

    /// An asset represented by a URL.
    ///
    /// - Parameters:
    ///   - url: The URL of the content to be played.
    ///   - configuration: The configuration for the asset.
    ///   - metadata: The metadata associated with the asset.
    ///   - customData: Optional custom data to associate with the asset. Use `Encodable.encoded(using:)`
    ///     to convert an `Encodable` value into a `CastCustomData`.
    ///
    /// Some assets require additional configuration to be played successfully. Provide these using the
    /// `configuration` parameter.
    public static func url(_ url: URL, configuration: CastAssetURLConfiguration = .init(), metadata: CastMetadata?, customData: CastCustomData? = nil) -> Self {
        .init(kind: .url(url, configuration: configuration), metadata: metadata, customData: customData)
    }

    /// An asset represented by a URL.
    ///
    /// - Parameters:
    ///   - url: The URL of the content to be played.
    ///   - configuration: The configuration for the asset.
    ///   - metadata: The metadata associated with the asset.
    ///   - customData: Optional custom data to associate with the asset, encoded using the default `JSONEncoder`.
    ///
    /// Some assets require additional configuration to be played successfully. Provide these using the
    /// `configuration` parameter.
    public static func url<T>(
        _ url: URL,
        configuration: CastAssetURLConfiguration = .init(),
        metadata: CastMetadata?,
        customData: T
    ) -> Self where T: Encodable {
        .init(kind: .url(url, configuration: configuration), metadata: metadata, customData: customData.encoded(using: JSONEncoder()))
    }

    private static func kind(from rawMediaInformation: GCKMediaInformation) -> Kind? {
        if let entity = rawMediaInformation.entity {
            return .entity(entity)
        }
        else if let identifier = rawMediaInformation.contentID {
            return .identifier(identifier)
        }
        else if let url = rawMediaInformation.contentURL {
            return .url(url, configuration: .init(
                mimeType: rawMediaInformation.contentType,
                hlsAudioSegmentFormat: rawMediaInformation.hlsSegmentFormat,
                hlsVideoSegmentFormat: rawMediaInformation.hlsVideoSegmentFormat
            ))
        }
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
    /// A type of asset.
    enum Kind {
        /// Entity.
        ///
        /// An entity is the suggested property to use in your implementation for both your sender and receiver apps.
        /// It is a deep link URL that represents a single media item and that your receiver should be able to handle.
        case entity(String)

        /// Identifier.
        case identifier(String)

        /// URL.
        ///
        /// Some assets require additional configuration to be played successfully. Provide these using the
        /// `configuration` parameter.
        case url(URL, configuration: CastAssetURLConfiguration)

        func mediaInformationBuilder() -> GCKMediaInformationBuilder {
            switch self {
            case let .entity(entity):
                return GCKMediaInformationBuilder(entity: entity)
            case let .identifier(identifier):
                let builder = GCKMediaInformationBuilder()
                builder.contentID = identifier
                return builder
            case let .url(url, configuration: configuration):
                let builder = GCKMediaInformationBuilder(contentURL: url)
                builder.contentType = configuration.mimeType
                builder.hlsSegmentFormat = configuration.hlsAudioSegmentFormat
                builder.hlsVideoSegmentFormat = configuration.hlsVideoSegmentFormat
                return builder
            }
        }
    }
}

extension CastAsset {
    static func name(for asset: CastAsset?) -> String {
        guard let asset else {
            return String(localized: "Idle", bundle: .module, comment: "Generic label displayed when the Cast receiver is idle")
        }
        return asset.metadata?.title ?? String(localized: "Unknown", bundle: .module, comment: "Generic name for a Cast asset")
    }
}
