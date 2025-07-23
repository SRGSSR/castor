//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import GoogleCast

/// A cast asset representing content to be played.
public struct CastAsset {
    private let resource: CastMediaInformation
    private let customData: Any?
    private let configuration: CastPlaybackConfiguration

    public init(resource: CastMediaInformation, customData: Any? = nil, configuration: CastPlaybackConfiguration = .init()) {
        self.resource = resource
        self.customData = customData
        self.configuration = configuration
    }

    /// A simple asset which can be played directly.
    ///
    /// - Parameters:
    ///   - url: The URL to be played.
    ///   - metadata: The metadata associated with the asset.
    ///   - configuration: The playback configuration.
    /// - Returns: The asset.
    public static func simple(url: URL, metadata: CastMetadata?, customData: Any? = nil, configuration: CastPlaybackConfiguration = .init()) -> Self {
        self.init(resource: .simple(url: url, metadata: metadata), customData: customData, configuration: configuration)
    }

    /// A custom asset represented by some identifier..
    ///
    /// - Parameters:
    ///   - identifier: An identifier for the content to be played.
    ///   - metadata: The metadata associated with the asset.
    ///   - configuration: The playback configuration.
    /// - Returns: The asset.
    public static func custom(identifier: String, metadata: CastMetadata?, customData: Any? = nil, configuration: CastPlaybackConfiguration = .init()) -> Self {
        self.init(resource: .custom(identifier: identifier, metadata: metadata), customData: customData, configuration: configuration)
    }

    func rawItem() -> GCKMediaQueueItem {
        let builder = GCKMediaQueueItemBuilder()
        builder.mediaInformation = resource.rawMediaInformation
        builder.autoplay = configuration.autoplay
        builder.customData = customData
        return builder.build()
    }
}
